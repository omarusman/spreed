<?php
declare(strict_types=1);
/**
 * @copyright Copyright (c) 2019 Joas Schilling <coding@schilljs.com>
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

namespace OCA\Spreed\Chat\Command;


use OCA\Spreed\Model\Command;
use OCA\Spreed\Room;
use OCA\Spreed\Service\CommandService;
use OCP\AppFramework\Db\DoesNotExistException;
use OCP\Comments\IComment;
use OCP\IL10N;
use OCP\ILogger;
use Symfony\Component\EventDispatcher\EventDispatcherInterface;
use Symfony\Component\EventDispatcher\GenericEvent;

class Executor {

	public const PLACEHOLDER_ROOM = '{ROOM}';
	public const PLACEHOLDER_USER = '{USER}';
	public const PLACEHOLDER_ARGUMENTS = '{ARGUMENTS}';
	public const PLACEHOLDER_ARGUMENTS_DOUBLEQUOTE_ESCAPED = '{ARGUMENTS_DOUBLEQUOTE_ESCAPED}';

	/** @var EventDispatcherInterface */
	protected $dispatcher;

	/** @var ShellExecutor */
	protected $shellExecutor;

	/** @var CommandService */
	protected $commandService;

	/** @var ILogger */
	protected $logger;

	/** @var IL10N */
	protected $l;

	public function __construct(EventDispatcherInterface $dispatcher,
								ShellExecutor $shellExecutor,
								CommandService $commandService,
								ILogger $logger,
								IL10N $l) {
		$this->dispatcher = $dispatcher;
		$this->shellExecutor = $shellExecutor;
		$this->commandService = $commandService;
		$this->logger = $logger;
		$this->l = $l;
	}

	public function exec(Room $room, IComment $message, Command $command, string $arguments): void {
		try {
			$command = $this->commandService->resolveAlias($command);
		} catch (DoesNotExistException $e) {
			$user = $message->getActorType() === 'users' ? $message->getActorId() : '';
			$message->setMessage(json_encode([
				'user' => $user,
				'visibility' => $command->getResponse(),
				'output' => $e->getMessage(),
			]));
			$message->setActor('bots', $command->getName());
			$message->setVerb('command');
			return;
		}

		if ($command->getApp() === '' && $command->getCommand() === 'help') {
			$output = $this->execHelp($room, $message, $arguments);
		} else if ($command->getApp() !== '') {
			$output = $this->execApp($room, $message, $command, $arguments);
		} else  {
			$output = $this->execShell($room, $message, $command, $arguments);
		}

		$user = $message->getActorType() === 'users' ? $message->getActorId() : '';
		$message->setMessage(json_encode([
			'user' => $user,
			'visibility' => $command->getResponse(),
			'output' => $output,
		]));
		$message->setActor('bots', $command->getName());
		$message->setVerb('command');
	}

	protected function execHelp(Room $room, IComment $message, string $arguments): string {
		if ($arguments !== '' && $arguments !== 'help') {
			return $this->execHelpSingleCommand($room, $message, $arguments);
		}

		$helps = [];
		$commands = $this->commandService->findAll();

		foreach ($commands as $command) {
			if ($command->getApp() !== '') {
				$response = $this->execHelpSingleCommand($room, $message, $command->getApp() . ' ' . $command->getCommand());
			} else {
				if ($command->getCommand() === 'help') {
					continue;
				}
				$response = $this->execHelpSingleCommand($room, $message, $command->getCommand());
			}

			$response = trim($response);
			if (strpos($response, "\n")) {
				$helps[] = substr($response, 0, strpos($response, "\n"));
			} else {
				$helps[] = $response;
			}
		}

		if (empty($helps)) {
			return $this->l->t('There are currently no commands available.');
		}

		// FIXME Implement a useful help
		return implode("\n", $helps);
	}

	protected function execHelpSingleCommand(Room $room, IComment $message, string $arguments): string {
		try {
			$input = explode(' ', $arguments, 2);
			if (count($input) === 1) {
				$command = $this->commandService->find('', $arguments);
				return $this->execShell($room, $message, $command, '--help');
			}

			[$app, $cmd] = $input;
			$command = $this->commandService->find($app, $cmd);
			return $this->execApp($room, $message, $command, '--help');
		} catch (DoesNotExistException $e) {
			return $this->l->t('The command does not exist');
		}
	}

	protected function execApp(Room $room, IComment $message, Command $command, string $arguments): string {
		$event = $this->createEvent($command);
		$event->setArguments([
			'room' => $room,
			'message' => $message,
			'arguments' => $arguments,
			'output' => '',
		]);

		$this->dispatcher->dispatch(self::class . '::execApp', $event);

		return (string) $event->getArgument('output');
	}

	protected function createEvent(Command $command): GenericEvent {
		return new GenericEvent($command);
	}

	public function execShell(Room $room, IComment $message, Command $command, string $arguments): string {
		try {
			return $this->shellExecutor->execShell(
				$command->getScript(),
				$arguments,
				$room->getToken(),
				$message->getActorType() === 'users' ? $message->getActorId() : ''
			);
		} catch (\InvalidArgumentException $e) {
			$this->logger->logException($e);
			return '';
		}
	}
}
