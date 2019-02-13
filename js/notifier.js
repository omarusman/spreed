/**
 * Web Browser Notification.
 *
 * Responsible for firing web browser notification,
 * for every new message received.
 *
 * @author Oozman <hi@oozman>
 */
(function (OCA, OC, $) {
    'use strict';

    /**
     * Set notification audio file path.
     *
     * @type {string}
     */
    var basePath = OC.generateUrl("").replace("/index.php/", "");
    var audioFile = basePath + "/custom_apps/spreed/audio/notify.mp3";

    // if not in localhost, do the right audio path.
    if ($(location).attr("href").search("//localhost") < 0) {
        audioFile = basePath + "/apps/spreed/audio/notify.mp3";
    }

    /**
     * Sync Room Channel
     * This will be the channel where we do a sync room event.
     *
     * @see signaling.js
     */
    var syncRoomChannel = Backbone.Radio.channel("syncRooms");

    /**
     * Timeout interval in seconds.
     * @type {*|{}}
     */
    var interval = 5000;

    OCA.Talk = OCA.Talk || {};
    OCA.Talk.Notifier = {
        // iNotify instance.
        notifier: new Notify({
            effect: 'scroll',
            interval: 300,
            audio: {
                file: audioFile
            },
            updateFavicon: {
                textColor: "#222",
                backgroundColor: "#FDCD4D"
            }
        }).setFavicon("..."),

        // The last rooms data. Useful for not firing duplicate notifications.
        rooms: [],

        // The notification queue.
        notificationQueue: [],

        init: function () {

            var self = this;

            syncRoomChannel.on("doSyncRooms", function () {

                self.getChatRooms();
                self.checkNewMessagesInRooms();
                self.checkUnreadMessagesInRooms();
            });

            syncRoomChannel.trigger("doSyncRooms");
            self.fireNotifications();
        },

        getChatRooms: function () {

            var self = this;

            $.ajax({
                url: OC.linkToOCS('apps/spreed/api/v1', 2) + "room",
                headers: {'Accept': 'application/json'},
                type: 'GET'
            }).done(function (response) {

                var rooms = response.ocs.data;

                _.each(rooms, function (room) {

                    // Check if room is already added to rooms list.
                    var found = _.findWhere(self.rooms, {token: room.token});

                    // If not yet in the rooms list, add it.
                    if (_.isUndefined(found)) {
                        self.rooms.push({token: room.token, lastMessageId: room.lastMessage.id, unreadMessages: room.unreadMessages});
                    } else { // If found, update unreadMessages.

                        var index = _.findIndex(self.rooms, function (r) {
                            return r.token === room.token;
                        });

                        // Update unread messages.
                        if (index > -1) {
                            self.rooms[index].unreadMessages = room.unreadMessages;
                        }
                    }
                });
            });
        },

        checkNewMessagesInRooms: function () {

            var self = this;

            _.each(self.rooms, function (room) {

                $.ajax({
                    url: OC.linkToOCS('apps/spreed/api/v1', 2) + "chat/" + room.token,
                    type: "GET",
                    headers: {"Accept": "application/json"},
                    data: {
                        limit: 1
                    }
                }).done(function (response) {

                    // Get latest message.
                    var message = _.first(response.ocs.data);

                    // This means, we have a new message.
                    if (!_.isEqual(room.lastMessageId, message.id)) {

                        // Get the room index.
                        var index = _.findIndex(self.rooms, function (r) {
                            return r.token === room.token;
                        });

                        if (index > -1) {

                            // Update last message id of this room.
                            self.rooms[index] = {token: room.token, lastMessageId: message.id};

                            // Send a notification.
                            // If not to own self.
                            if (!_.isEqual(OC.getCurrentUser().displayName, message.actorDisplayName)) {

                                self.notificationQueue.push({
                                    title: "New Message",
                                    msg: "You have a new message from " + message.actorDisplayName,
                                    token: room.token
                                });
                            }
                        }
                    }
                });
            });
        },

        checkUnreadMessagesInRooms: function () {

            var self = this;
            var unreadMessages = 0;

            _.each(self.rooms, function (room) {
                unreadMessages += room.unreadMessages;
            });

            if (unreadMessages > 0) {
                self.notifier.setTitle("You have " + unreadMessages + " unread messages.");
            } else {
                self.notifier.setTitle();
            }

            return true;
        },

        fireNotifications: function () {

            var self = this;

            $.doTimeout("fire-notifications", interval, function () {

                if (self.notificationQueue.length <= 0) return true;

                var first = _.first(self.notificationQueue);
                self.notify(first.title, first.msg, first.token);

                self.notificationQueue = _.without(self.notificationQueue, first);

                return true;
            });
        },

        notify: function (title, message, token) {

            // Clear everything first.
            this.notifier.setTitle();

            this.notifier.setTitle(message);
            this.notifier.notify({
                title: title,
                openurl: OC.generateUrl('call/' + token),
                body: message
            }).player();
        }
    }
})(OCA, OC, $);
