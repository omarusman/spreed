<?php
declare(strict_types=1);
/**
 * @copyright Copyright (c) 2016 Joas Schilling <coding@schilljs.com>
 *
 * @license GNU AGPL version 3 or any later version
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

namespace OCA\Spreed\Notification;


use OCA\Spreed\Chat\MessageParser;
use OCA\Spreed\Config;
use OCA\Spreed\Exceptions\ParticipantNotFoundException;
use OCA\Spreed\Exceptions\RoomNotFoundException;
use OCA\Spreed\Manager;
use OCA\Spreed\Participant;
use OCA\Spreed\Room;
use OCP\Comments\ICommentsManager;
use OCP\Comments\NotFoundException;
use OCP\IL10N;
use OCP\IURLGenerator;
use OCP\IUser;
use OCP\IUserManager;
use OCP\L10N\IFactory;
use OCP\Notification\IManager as INotificationManager;
use OCP\Notification\INotification;
use OCP\Notification\INotifier;
use OCP\RichObjectStrings\Definitions;
use OCP\Share;
use OCP\Share\Exceptions\ShareNotFound;
use OCP\Share\IManager as IShareManager;

class Notifier implements INotifier {

	/** @var IFactory */
	protected $lFactory;
	/** @var IURLGenerator */
	protected $url;
	/** @var Config */
	protected $config;
	/** @var IUserManager */
	protected $userManager;
	/** @var IShareManager */
	private $shareManager;
	/** @var Manager */
	protected $manager;
	/** @var INotificationManager */
	protected $notificationManager;
	/** @var ICommentsManager */
	protected $commentManager;
	/** @var MessageParser */
	protected $messageParser;
	/** @var Definitions */
	protected $definitions;

	public function __construct(IFactory $lFactory,
								IURLGenerator $url,
								Config $config,
								IUserManager $userManager,
								IShareManager $shareManager,
								Manager $manager,
								INotificationManager $notificationManager,
								ICommentsManager $commentManager,
								MessageParser $messageParser,
								Definitions $definitions) {
		$this->lFactory = $lFactory;
		$this->url = $url;
		$this->config = $config;
		$this->userManager = $userManager;
		$this->shareManager = $shareManager;
		$this->manager = $manager;
		$this->notificationManager = $notificationManager;
		$this->commentManager = $commentManager;
		$this->messageParser = $messageParser;
		$this->definitions = $definitions;
	}

	/**
	 * @param INotification $notification
	 * @param string $languageCode The code of the language that should be used to prepare the notification
	 * @return INotification
	 * @throws \InvalidArgumentException When the notification was not prepared by a notifier
	 * @since 9.0.0
	 */
	public function prepare(INotification $notification, $languageCode): INotification {
		if ($notification->getApp() !== 'spreed') {
			throw new \InvalidArgumentException('Incorrect app');
		}

		$userId = $notification->getUser();
		$user = $this->userManager->get($userId);
		if (!$user instanceof IUser || $this->config->isDisabledForUser($user)) {
			$this->notificationManager->markProcessed($notification);
			throw new \InvalidArgumentException('User can not use Talk');
		}

		$l = $this->lFactory->get('spreed', $languageCode);

		try {
			$room = $this->manager->getRoomByToken($notification->getObjectId());
		} catch (RoomNotFoundException $e) {
			try {
				// Before 3.2.3 the id was passed in notifications
				$room = $this->manager->getRoomById((int) $notification->getObjectId());
			} catch (RoomNotFoundException $e) {
				// Room does not exist
				$this->notificationManager->markProcessed($notification);
				throw new \InvalidArgumentException('Invalid room');
			}
		}

		try {
			$participant = $room->getParticipant($userId);
		} catch (ParticipantNotFoundException $e) {
			// Room does not exist
			$this->notificationManager->markProcessed($notification);
			throw new \InvalidArgumentException('User is not part of the room anymore');
		}

		$notification
			->setIcon($this->url->getAbsoluteURL($this->url->imagePath('spreed', 'app-dark.svg')))
			->setLink($this->url->linkToRouteAbsolute('spreed.pagecontroller.showCall', ['token' => $room->getToken()]));

		$subject = $notification->getSubject();
		if ($subject === 'invitation') {
			return $this->parseInvitation($notification, $room, $l);
		}
		if ($subject === 'call') {
			if ($room->getObjectType() === 'share:password') {
				return $this->parsePasswordRequest($notification, $room, $l);
			}
			return $this->parseCall($notification, $room, $l);
		}
		if ($subject === 'mention' ||  $subject === 'chat') {
			return $this->parseChatMessage($notification, $room, $participant, $l);
		}

		$this->notificationManager->markProcessed($notification);
		throw new \InvalidArgumentException('Unknown subject');
	}

	/**
	 * @param INotification $notification
	 * @param Room $room
	 * @param Participant $participant
	 * @param IL10N $l
	 * @return INotification
	 * @throws \InvalidArgumentException
	 */
	protected function parseChatMessage(INotification $notification, Room $room, Participant $participant, IL10N $l): INotification {
		if ($notification->getObjectType() !== 'chat') {
			throw new \InvalidArgumentException('Unknown object type');
		}

		$subjectParameters = $notification->getSubjectParameters();

		$richSubjectUser = null;
		$isGuest = false;
		if ($subjectParameters['userType'] === 'users') {
			$userId = $subjectParameters['userId'];
			$user = $this->userManager->get($userId);

			if ($user instanceof IUser) {
				$richSubjectUser = [
					'type' => 'user',
					'id' => $userId,
					'name' => $user->getDisplayName(),
				];
			}
		} else {
			$isGuest = true;
		}

		$richSubjectCall = [
			'type' => 'call',
			'id' => $room->getId(),
			'name' => $room->getDisplayName($notification->getUser()),
			'call-type' => $this->getRoomType($room),
		];

		$messageParameters = $notification->getMessageParameters();
		if (!isset($messageParameters['commentId'])) {
			throw new \InvalidArgumentException('Unknown comment');
		}

		try {
			$comment = $this->commentManager->get($messageParameters['commentId']);
		} catch (NotFoundException $e) {
			throw new \InvalidArgumentException('Unknown comment');
		}

		$message = $this->messageParser->createMessage($room, $participant, $comment, $l);
		$this->messageParser->parseMessage($message);

		if (!$message->getVisibility()) {
			throw new \InvalidArgumentException('Invisible comment');
		}

		$placeholders = $replacements = [];
		foreach ($message->getMessageParameters() as $placeholder => $parameter) {
			$placeholders[] = '{' . $placeholder . '}';
			if ($parameter['type'] === 'user') {
				$replacements[] = '@' . $parameter['name'];
			} else {
				$replacements[] = $parameter['name'];
			}
		}

		$notification->setParsedMessage(str_replace($placeholders, $replacements, $message->getMessage()));
		$notification->setRichMessage($message->getMessage(), $message->getMessageParameters());

		$richSubjectParameters = [
			'user' => $richSubjectUser,
			'call' => $richSubjectCall,
		];

		if ($notification->getSubject() === 'chat') {
			if ($room->getType() === Room::ONE_TO_ONE_CALL) {
				$subject = $l->t('{user} sent you a private message');
			} else {
				if ($richSubjectUser) {
					$subject = $l->t('{user} sent a message in conversation {call}');
				} else if (!$isGuest) {
					$subject = $l->t('A deleted user sent a message in conversation {call}');
				} else {
					$subject = $l->t('A guest sent a message in conversation {call}');
				}
			}
		} else if ($room->getType() === Room::ONE_TO_ONE_CALL) {
			$subject = $l->t('{user} mentioned you in a private conversation');
		} else {
			if ($richSubjectUser) {
				$subject = $l->t('{user} mentioned you in conversation {call}');
			} else if (!$isGuest) {
				$subject = $l->t('A deleted user mentioned you in conversation {call}');
			} else {
				$subject = $l->t('A guest mentioned you in conversation {call}');
			}
		}

		if ($richSubjectParameters['user'] === null) {
			unset($richSubjectParameters['user']);
		}

		$placeholders = $replacements = [];
		foreach ($richSubjectParameters as $placeholder => $parameter) {
			$placeholders[] = '{' . $placeholder . '}';
			$replacements[] = $parameter['name'];
		}

		$notification->setParsedSubject(str_replace($placeholders, $replacements, $subject))
			->setRichSubject($subject, $richSubjectParameters);

		return $notification;
	}

	/**
	 * @param Room $room
	 * @return string
	 * @throws \InvalidArgumentException
	 */
	protected function getRoomType(Room $room): string {
		switch ($room->getType()) {
			case Room::ONE_TO_ONE_CALL:
				return 'one2one';
			case Room::GROUP_CALL:
				return 'group';
			case Room::PUBLIC_CALL:
				return 'public';
			default:
				throw new \InvalidArgumentException('Unknown room type');
		}
	}

	/**
	 * @param INotification $notification
	 * @param Room $room
	 * @param IL10N $l
	 * @return INotification
	 * @throws \InvalidArgumentException
	 */
	protected function parseInvitation(INotification $notification, Room $room, IL10N $l): INotification {
		if ($notification->getObjectType() !== 'room') {
			throw new \InvalidArgumentException('Unknown object type');
		}

		$parameters = $notification->getSubjectParameters();
		$uid = $parameters['actorId'] ?? $parameters[0];

		$user = $this->userManager->get($uid);
		if (!$user instanceof IUser) {
			throw new \InvalidArgumentException('Calling user does not exist anymore');
		}

		$roomName = $room->getDisplayName($notification->getUser());
		if ($room->getType() === Room::ONE_TO_ONE_CALL) {
			$notification
				->setParsedSubject(
					$l->t('%s invited you to a private conversation', [$user->getDisplayName()])
				)
				->setRichSubject(
					$l->t('{user} invited you to a private conversation'), [
						'user' => [
							'type' => 'user',
							'id' => $uid,
							'name' => $user->getDisplayName(),
						],
						'call' => [
							'type' => 'call',
							'id' => $room->getId(),
							'name' => $roomName,
							'call-type' => $this->getRoomType($room),
						],
					]
				);

		} else if (\in_array($room->getType(), [Room::GROUP_CALL, Room::PUBLIC_CALL], true)) {
			$notification
				->setParsedSubject(
					$l->t('%s invited you to a group conversation: %s', [$user->getDisplayName(), $roomName])
				)
				->setRichSubject(
					$l->t('{user} invited you to a group conversation: {call}'), [
						'user' => [
							'type' => 'user',
							'id' => $uid,
							'name' => $user->getDisplayName(),
						],
						'call' => [
							'type' => 'call',
							'id' => $room->getId(),
							'name' => $roomName,
							'call-type' => $this->getRoomType($room),
						],
					]
				);
		} else {
			throw new \InvalidArgumentException('Unknown room type');
		}

		return $notification;
	}

	/**
	 * @param INotification $notification
	 * @param Room $room
	 * @param IL10N $l
	 * @return INotification
	 * @throws \InvalidArgumentException
	 */
	protected function parseCall(INotification $notification, Room $room, IL10N $l): INotification {
		if ($notification->getObjectType() !== 'call') {
			throw new \InvalidArgumentException('Unknown object type');
		}

		$roomName = $room->getDisplayName($notification->getUser());
		if ($room->getType() === Room::ONE_TO_ONE_CALL) {
			$parameters = $notification->getSubjectParameters();
			$calleeId = $parameters['callee'];
			$user = $this->userManager->get($calleeId);
			if ($user instanceof IUser) {
				$notification
					->setParsedSubject(
						str_replace('{user}', $user->getDisplayName(), $l->t('{user} wants to talk with you'))
					)
					->setRichSubject(
						$l->t('{user} wants to talk with you'), [
							'user' => [
								'type' => 'user',
								'id' => $calleeId,
								'name' => $user->getDisplayName(),
							],
							'call' => [
								'type' => 'call',
								'id' => $room->getId(),
								'name' => $roomName,
								'call-type' => $this->getRoomType($room),
							],
						]
					);
			} else {
				throw new \InvalidArgumentException('Calling user does not exist anymore');
			}

		} else if (\in_array($room->getType(), [Room::GROUP_CALL, Room::PUBLIC_CALL], true)) {
			$notification
				->setParsedSubject(
					str_replace('{call}', $roomName, $l->t('A group call has started in {call}'))
				)
				->setRichSubject(
					$l->t('A group call has started in {call}'), [
						'call' => [
							'type' => 'call',
							'id' => $room->getId(),
							'name' => $roomName,
							'call-type' => $this->getRoomType($room),
						],
					]
				);

		} else {
			throw new \InvalidArgumentException('Unknown room type');
		}

		return $notification;
	}

	/**
	 * @param INotification $notification
	 * @param Room $room
	 * @param IL10N $l
	 * @return INotification
	 * @throws \InvalidArgumentException
	 */
	protected function parsePasswordRequest(INotification $notification, Room $room, IL10N $l): INotification {
		if ($notification->getObjectType() !== 'call') {
			throw new \InvalidArgumentException('Unknown object type');
		}

		try {
			$share = $this->shareManager->getShareByToken($room->getObjectId());
		} catch (ShareNotFound $e) {
			throw new \InvalidArgumentException('Unknown share');
		}

		try {
			$file = [
				'type' => 'highlight',
				'id' => $share->getNodeId(),
				'name' => $share->getNode()->getName(),
			];
		} catch (\OCP\Files\NotFoundException $e) {
			throw new \InvalidArgumentException('Unknown file');
		}

		if ($share->getShareType() === Share::SHARE_TYPE_EMAIL) {
			$sharedWith = $share->getSharedWith();

			$notification
				->setParsedSubject(str_replace(['{email}', '{file}'], [$sharedWith, $file['name']], $l->t('{email} requested the password to access {file}')))
				->setRichSubject(
					$l->t('{email} requested the password to access {file}'),
					[
						'email' => [
							'type' => 'email',
							'id' => $sharedWith,
							'name' => $sharedWith,
						],
						'file' => $file,
					]
				);
		} else {
			$notification
				->setParsedSubject(str_replace('{file}', $file['name'], $l->t('Someone requested the password to access {file}')))
				->setRichSubject($l->t('Someone requested the password to access {file}'), ['file' => $file]);
		}

		return $notification;
	}
}
