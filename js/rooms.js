// TODO(fancycode): Should load through AMD if possible.
/* global OC, OCA */

(function(OCA, OC, $) {
	'use strict';

	OCA.SpreedMe = OCA.SpreedMe || {};

	function initRooms() {

		var editRoomname = $('#edit-roomname');
		editRoomname.keyup(function () {
			editRoomname.tooltip('hide');
			editRoomname.removeClass('error');
		});
	}

	var currentRoomId = 0;
	var roomChannel = Backbone.Radio.channel('rooms');

	OCA.SpreedMe.Rooms = {
		showCamera: function() {
			$('.videoView').removeClass('hidden');
		},
		createOneToOneVideoCall: function(recipientUserId) {
			console.log(recipientUserId);
			$.ajax({
				url: OC.generateUrl('/apps/spreed/api/oneToOne'),
				type: 'PUT',
				data: 'targetUserName='+recipientUserId,
				success: function(data) {
					window.location.href = "#" + data.roomId;
				}
			});
		},
		createGroupVideoCall: function(groupId) {
			console.log(groupId);
			$.ajax({
				url: OC.generateUrl('/apps/spreed/api/group'),
				type: 'PUT',
				data: 'targetGroupName='+groupId,
				success: function(data) {
					window.location.href = "#" + data.roomId;
				}
			});
		},
		join: function(roomId) {
			$('#emptycontent').hide();
			$('.videoView').addClass('hidden');
			$('#app-content').addClass('icon-loading');

			OCA.SpreedMe.webrtc.leaveRoom();

			currentRoomId = roomId;
			OCA.SpreedMe.webrtc.joinRoom(roomId);
			OCA.SpreedMe.Rooms.ping();
		},
		currentRoom: function() {
			return currentRoomId;
		},
		peers: function(roomId) {
			return $.ajax({
				url: OC.generateUrl('/apps/spreed/api/room/{roomId}/peers', {roomId: roomId})
			});
		},
		ping: function() {
			$.post(
				OC.generateUrl('/apps/spreed/api/ping'),
				{
					currentRoom: OCA.SpreedMe.Rooms.currentRoom()
				}
			);
		}
	};

	OCA.SpreedMe.initRooms = initRooms;

})(OCA, OC, $);
