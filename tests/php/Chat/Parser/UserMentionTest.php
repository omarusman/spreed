<?php
declare(strict_types=1);
/**
 *
 * @copyright Copyright (c) 2017, Daniel Calviño Sánchez (danxuliu@gmail.com)
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

namespace OCA\Spreed\Tests\php\Chat\Parser;

use OCA\Spreed\Chat\Parser\UserMention;
use OCA\Spreed\Model\Message;
use OCA\Spreed\Participant;
use OCA\Spreed\Room;
use OCP\Comments\IComment;
use OCP\Comments\ICommentsManager;
use OCP\IL10N;
use OCP\IUser;
use OCP\IUserManager;
use PHPUnit\Framework\MockObject\MockObject;

class UserMentionTest extends \Test\TestCase {

	/** @var ICommentsManager|MockObject */
	protected $commentsManager;
	/** @var IUserManager|MockObject */
	protected $userManager;
	/** @var IL10N|MockObject */
	protected $l;

	/** @var UserMention */
	protected $parser;

	public function setUp() {
		parent::setUp();

		$this->commentsManager = $this->createMock(ICommentsManager::class);
		$this->userManager = $this->createMock(IUserManager::class);
		$this->l = $this->createMock(IL10N::class);

		$this->parser = new UserMention($this->commentsManager, $this->userManager, $this->l);
	}

	/**
	 * @param array $mentions
	 * @return MockObject|IComment
	 */
	private function newComment(array $mentions): IComment {
		$comment = $this->createMock(IComment::class);

		$comment->method('getMentions')->willReturn($mentions);

		return $comment;
	}

	public function testGetRichMessageWithoutEnrichableReferences() {
		$comment = $this->newComment([]);

		/** @var Room|MockObject $room */
		$room = $this->createMock(Room::class);
		/** @var Participant|MockObject $participant */
		$participant = $this->createMock(Participant::class);
		/** @var IL10N|MockObject $l */
		$l = $this->createMock(IL10N::class);
		$chatMessage = new Message($room, $participant, $comment, $l);
		$chatMessage->setMessage('Message without enrichable references', []);

		$this->parser->parseMessage($chatMessage);

		$this->assertEquals('Message without enrichable references', $chatMessage->getMessage());
		$this->assertEquals([], $chatMessage->getMessageParameters());
	}

	public function testGetRichMessageWithSingleMention() {
		$mentions = [
			['type'=>'user', 'id'=>'testUser'],
		];
		$comment = $this->newComment($mentions);

		$this->commentsManager->expects($this->once())
			->method('resolveDisplayName')
			->with('user', 'testUser')
			->willReturn('testUser display name');

		$this->userManager->expects($this->once())
			->method('get')
			->with('testUser')
			->willReturn($this->createMock(IUser::class));

		/** @var Room|MockObject $room */
		$room = $this->createMock(Room::class);
		/** @var Participant|MockObject $participant */
		$participant = $this->createMock(Participant::class);
		/** @var IL10N|MockObject $l */
		$l = $this->createMock(IL10N::class);
		$chatMessage = new Message($room, $participant, $comment, $l);
		$chatMessage->setMessage('Mention to @testUser', []);

		$this->parser->parseMessage($chatMessage);

		$expectedMessageParameters = [
			'mention-user1' => [
				'type' => 'user',
				'id' => 'testUser',
				'name' => 'testUser display name'
			]
		];

		$this->assertEquals('Mention to {mention-user1}', $chatMessage->getMessage());
		$this->assertEquals($expectedMessageParameters, $chatMessage->getMessageParameters());
	}

	public function testGetRichMessageWithDuplicatedMention() {
		$mentions = [
			['type'=>'user', 'id'=>'testUser'],
		];
		$comment = $this->newComment($mentions);

		$this->commentsManager->expects($this->once())
			->method('resolveDisplayName')
			->with('user', 'testUser')
			->willReturn('testUser display name');

		$this->userManager->expects($this->once())
			->method('get')
			->with('testUser')
			->willReturn($this->createMock(IUser::class));

		/** @var Room|MockObject $room */
		$room = $this->createMock(Room::class);
		/** @var Participant|MockObject $participant */
		$participant = $this->createMock(Participant::class);
		/** @var IL10N|MockObject $l */
		$l = $this->createMock(IL10N::class);
		$chatMessage = new Message($room, $participant, $comment, $l);
		$chatMessage->setMessage('Mention to @testUser and @testUser again', []);

		$this->parser->parseMessage($chatMessage);

		$expectedMessageParameters = [
			'mention-user1' => [
				'type' => 'user',
				'id' => 'testUser',
				'name' => 'testUser display name'
			]
		];

		$this->assertEquals('Mention to {mention-user1} and {mention-user1} again', $chatMessage->getMessage());
		$this->assertEquals($expectedMessageParameters, $chatMessage->getMessageParameters());
	}

	public function testGetRichMessageWithSeveralMentions() {
		$mentions = [
			['type'=>'user', 'id'=>'testUser1'],
			['type'=>'user', 'id'=>'testUser2'],
			['type'=>'user', 'id'=>'testUser3']
		];
		$comment = $this->newComment($mentions);

		$this->commentsManager->expects($this->exactly(3))
			->method('resolveDisplayName')
			->withConsecutive(
				['user', 'testUser1'],
				['user', 'testUser2'],
				['user', 'testUser3']
			)
			->willReturn(
				'testUser1 display name',
				'testUser2 display name',
				'testUser3 display name'
			);

		$this->userManager->expects($this->exactly(3))
			->method('get')
			->withConsecutive(
				['testUser1'],
				['testUser2'],
				['testUser3']
			)
			->willReturn($this->createMock(IUser::class));

		/** @var Room|MockObject $room */
		$room = $this->createMock(Room::class);
		/** @var Participant|MockObject $participant */
		$participant = $this->createMock(Participant::class);
		/** @var IL10N|MockObject $l */
		$l = $this->createMock(IL10N::class);
		$chatMessage = new Message($room, $participant, $comment, $l);
		$chatMessage->setMessage('Mention to @testUser1, @testUser2, @testUser1 again and @testUser3', []);

		$this->parser->parseMessage($chatMessage);

		$expectedMessageParameters = [
			'mention-user1' => [
				'type' => 'user',
				'id' => 'testUser1',
				'name' => 'testUser1 display name'
			],
			'mention-user2' => [
				'type' => 'user',
				'id' => 'testUser2',
				'name' => 'testUser2 display name'
			],
			'mention-user3' => [
				'type' => 'user',
				'id' => 'testUser3',
				'name' => 'testUser3 display name'
			]
		];

		$this->assertEquals('Mention to {mention-user1}, {mention-user2}, {mention-user1} again and {mention-user3}', $chatMessage->getMessage());
		$this->assertEquals($expectedMessageParameters, $chatMessage->getMessageParameters());
	}

	public function testGetRichMessageWithNonExistingUserMention() {
		$mentions = [
			['type'=>'user', 'id'=>'me'],
			['type'=>'user', 'id'=>'testUser'],
		];
		$comment = $this->newComment($mentions);

		$this->commentsManager->expects($this->once())
			->method('resolveDisplayName')
			->with('user', 'testUser')
			->willReturn('testUser display name');

		$this->userManager->expects($this->at(0))
			->method('get')
			->with('me')
			->willReturn(null);

		$this->userManager->expects($this->at(1))
			->method('get')
			->with('testUser')
			->willReturn($this->createMock(IUser::class));

		/** @var Room|MockObject $room */
		$room = $this->createMock(Room::class);
		/** @var Participant|MockObject $participant */
		$participant = $this->createMock(Participant::class);
		/** @var IL10N|MockObject $l */
		$l = $this->createMock(IL10N::class);
		$chatMessage = new Message($room, $participant, $comment, $l);
		$chatMessage->setMessage('Mention @me to @testUser', []);

		$this->parser->parseMessage($chatMessage);

		$expectedMessageParameters = [
			'mention-user1' => [
				'type' => 'user',
				'id' => 'testUser',
				'name' => 'testUser display name'
			]
		];

		$this->assertEquals('Mention @me to {mention-user1}', $chatMessage->getMessage());
		$this->assertEquals($expectedMessageParameters, $chatMessage->getMessageParameters());
	}

	public function testGetRichMessageWhenDisplayNameCanNotBeResolved() {
		$mentions = [
			['type'=>'user', 'id'=>'testUser'],
		];
		$comment = $this->newComment($mentions);

		$this->commentsManager->expects($this->once())
			->method('resolveDisplayName')
			->willThrowException(new \OutOfBoundsException());

		$this->userManager->expects($this->once())
			->method('get')
			->with('testUser')
			->willReturn($this->createMock(IUser::class));

		/** @var Room|MockObject $room */
		$room = $this->createMock(Room::class);
		/** @var Participant|MockObject $participant */
		$participant = $this->createMock(Participant::class);
		/** @var IL10N|MockObject $l */
		$l = $this->createMock(IL10N::class);
		$chatMessage = new Message($room, $participant, $comment, $l);
		$chatMessage->setMessage('Mention to @testUser', []);

		$this->parser->parseMessage($chatMessage);

		$expectedMessageParameters = [
			'mention-user1' => [
				'type' => 'user',
				'id' => 'testUser',
				'name' => ''
			]
		];

		$this->assertEquals('Mention to {mention-user1}', $chatMessage->getMessage());
		$this->assertEquals($expectedMessageParameters, $chatMessage->getMessageParameters());
	}

}
