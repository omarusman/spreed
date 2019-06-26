<?php
declare(strict_types=1);

/**
 *
 * @copyright Copyright (c) 2018, Daniel Calviño Sánchez (danxuliu@gmail.com)
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

namespace OCA\Spreed\Tests\php\Collaboration\Collaborators;

use OCA\Spreed\Collaboration\Collaborators\RoomPlugin;
use OCA\Spreed\Manager;
use OCA\Spreed\Room;
use OCP\Collaboration\Collaborators\ISearchResult;
use OCP\Collaboration\Collaborators\SearchResultType;
use OCP\IUser;
use OCP\IUserSession;
use OCP\Share;

class RoomPluginTest extends \Test\TestCase {

	/** @var Manager */
	protected $manager;

	/** @var IUserSession */
	protected $userSession;

	/** @var IUser */
	protected $user;

	/** @var ISearchResult */
	protected $searchResult;

	/** @var RoomPlugin */
	protected $plugin;

	public function setUp() {
		parent::setUp();

		$this->manager = $this->createMock(Manager::class);

		$this->user = $this->createMock(IUser::class);
		$this->user->expects($this->any())
			->method('getUID')
			->willReturn('user0');
		$this->userSession = $this->createMock(IUserSession::class);
		$this->userSession->expects($this->any())
			->method('getUser')
			->willReturn($this->user);

		$this->searchResult = $this->createMock(ISearchResult::class);

		$this->plugin = new RoomPlugin($this->manager, $this->userSession);
	}

	private function newRoom(int $type, string $token, string $name): Room {
		$room = $this->createMock(Room::class);

		$room->expects($this->any())
			->method('getType')
			->willReturn($type);

		$room->expects($this->any())
			->method('getToken')
			->willReturn($token);

		$room->expects($this->any())
			->method('getDisplayName')
			->willReturn($name);

		return $room;
	}

	private function newResult(string $label, string $shareWith): array {
		return [
			'label' => $label,
			'value' => [
				'shareType' => Share::SHARE_TYPE_ROOM,
				'shareWith' => $shareWith
			]
		];
	}

	public function searchProvider(): array {
		return [
			// Empty search term with no rooms
			['', 2, 0, [], [], [], false],

			// Empty search term with rooms
			['', 2, 0, [
				$this->newRoom(Room::GROUP_CALL, 'roomToken', 'Room name')
			], [], [], false],

			// Search term with no matches
			['Unmatched search term', 2, 0, [
				$this->newRoom(Room::GROUP_CALL, 'roomToken', 'Unmatched name')
			], [], [], false],

			// Search term with single wide match
			['room', 2, 0, [
				$this->newRoom(Room::GROUP_CALL, 'roomToken', 'Room name'),
				$this->newRoom(Room::GROUP_CALL, 'roomToken2', 'Unmatched name')
			], [], [
				$this->newResult('Room name', 'roomToken')
			], false],

			// Search term with single exact match
			['room name', 2, 0, [
				$this->newRoom(Room::GROUP_CALL, 'roomToken', 'Unmatched name'),
				$this->newRoom(Room::GROUP_CALL, 'roomToken2', 'Room name')
			], [
				$this->newResult('Room name', 'roomToken2')
			], [], false],

			// Search term with single exact match and single wide match
			['room name', 2, 0, [
				$this->newRoom(Room::GROUP_CALL, 'roomToken', 'Room name that also matches'),
				$this->newRoom(Room::GROUP_CALL, 'roomToken2', 'Room name')
			], [
				$this->newResult('Room name', 'roomToken2')
			], [
				$this->newResult('Room name that also matches', 'roomToken')
			], false],

			// Search term matching one-to-one rooms (not possible in practice
			// as one-to-one rooms do not have a name, but it would be if they
			// had, so it is included here for completeness).
			['room name', 2, 0, [
				$this->newRoom(Room::ONE_TO_ONE_CALL, 'roomToken', 'Room name that also matches'),
				$this->newRoom(Room::ONE_TO_ONE_CALL, 'roomToken2', 'Room name')
			], [
				$this->newResult('Room name', 'roomToken2')
			], [
				$this->newResult('Room name that also matches', 'roomToken')
			], false],

			// Search term matching public rooms
			['room name', 2, 0, [
				$this->newRoom(Room::PUBLIC_CALL, 'roomToken', 'Room name that also matches'),
				$this->newRoom(Room::PUBLIC_CALL, 'roomToken2', 'Room name')
			], [
				$this->newResult('Room name', 'roomToken2')
			], [
				$this->newResult('Room name that also matches', 'roomToken')
			], false],

			// Search term with several wide matches
			['room', 2, 0, [
				$this->newRoom(Room::GROUP_CALL, 'roomToken', 'Room name'),
				$this->newRoom(Room::GROUP_CALL, 'roomToken2', 'Another room name'),
				$this->newRoom(Room::GROUP_CALL, 'roomToken3', 'Room name'),
				$this->newRoom(Room::GROUP_CALL, 'roomToken4', 'Another room name')
			], [], [
				$this->newResult('Room name', 'roomToken'),
				$this->newResult('Another room name', 'roomToken2'),
				$this->newResult('Room name', 'roomToken3'),
				$this->newResult('Another room name', 'roomToken4'),
			], false],

			// Search term with several exact matches
			['room name', 2, 0, [
				$this->newRoom(Room::GROUP_CALL, 'roomToken', 'Room name'),
				$this->newRoom(Room::GROUP_CALL, 'roomToken2', 'Room name'),
				$this->newRoom(Room::GROUP_CALL, 'roomToken3', 'Room name'),
				$this->newRoom(Room::GROUP_CALL, 'roomToken4', 'Room name')
			], [
				$this->newResult('Room name', 'roomToken'),
				$this->newResult('Room name', 'roomToken2'),
				$this->newResult('Room name', 'roomToken3'),
				$this->newResult('Room name', 'roomToken4')
			], [], false],

			// Search term with several matches
			['room name', 2, 0, [
				$this->newRoom(Room::GROUP_CALL, 'roomToken', 'Room name'),
				$this->newRoom(Room::GROUP_CALL, 'roomToken2', 'Unmatched name'),
				$this->newRoom(Room::GROUP_CALL, 'roomToken3', 'Another room name'),
				$this->newRoom(Room::GROUP_CALL, 'roomToken4', 'Room name'),
				$this->newRoom(Room::ONE_TO_ONE_CALL, 'roomToken5', 'Room name'),
				$this->newRoom(Room::PUBLIC_CALL, 'roomToken6', 'Room name'),
				$this->newRoom(Room::GROUP_CALL, 'roomToken7', 'Another unmatched name'),
				$this->newRoom(Room::ONE_TO_ONE_CALL, 'roomToken8', 'Another unmatched name'),
				$this->newRoom(Room::PUBLIC_CALL, 'roomToken9', 'Another unmatched name'),
				$this->newRoom(Room::ONE_TO_ONE_CALL, 'roomToken10', 'Another room name'),
				$this->newRoom(Room::PUBLIC_CALL, 'roomToken11', 'Another room name')
			], [
				$this->newResult('Room name', 'roomToken'),
				$this->newResult('Room name', 'roomToken4'),
				$this->newResult('Room name', 'roomToken5'),
				$this->newResult('Room name', 'roomToken6')
			], [
				$this->newResult('Another room name', 'roomToken3'),
				$this->newResult('Another room name', 'roomToken10'),
				$this->newResult('Another room name', 'roomToken11')
			], false],
		];
	}

	/**
	 * @dataProvider searchProvider
	 *
	 * @param string $searchTerm
	 * @param bool $limit
	 * @param bool $offset
	 * @param array $roomsForParticipant
	 * @param array $expectedMatchesExact
	 * @param array $expectedMatches
	 * @param bool $expectedHasMoreResults
	 */
	public function testSearch(
		string $searchTerm,
		bool $limit,
		bool $offset,
		array $roomsForParticipant,
		array $expectedMatchesExact,
		array $expectedMatches,
		bool $expectedHasMoreResults
	) {
		$this->manager->expects($this->any())
			->method('getRoomsForParticipant')
			->with('user0')
			->willReturn($roomsForParticipant);

		$this->searchResult->expects($this->any())
			->method('addResultSet')
			->with(
				$this->callback(
					function(SearchResultType $searchResultType) {
						return $searchResultType->getLabel() === 'rooms';
					}
				),
				$expectedMatches,
				$expectedMatchesExact
			);

		$hasMoreResults = $this->plugin->search($searchTerm, $limit, $offset, $this->searchResult);

		$this->assertSame($expectedHasMoreResults, $hasMoreResults);
	}

}
