/*
 * @copyright Copyright (c) 2019 Julius Härtl <jus@bitgrid.net>
 *
 * @author Julius Härtl <jus@bitgrid.net>
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
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import Vue from 'vue'
import CollaborationView from './views/CollaborationView'

// eslint-disable-next-line no-unexpected-multiline
(function(OCP, OCA) {
	// eslint-disable-next-line
	__webpack_nonce__ = btoa(OC.requestToken)
	// eslint-disable-next-line
	__webpack_public_path__ = OC.linkTo('spreed', 'js/')

	Vue.prototype.t = t
	Vue.prototype.n = n
	Vue.prototype.OC = OC

	OCA.Talk = Object.assign({}, OCA.Talk)
	OCA.Talk.CollectionsTabView = {

		ComponentVM: null,
		MountingPoint: null,

		init(MountingPoint, roomModel) {
			this.ComponentVM = new Vue({
				data: {
					model: roomModel.toJSON()
				},
				render: h => h(CollaborationView)
			})

			if (MountingPoint) {
				this.ComponentVM.$mount(MountingPoint)
			}
		},
		setRoomModel(roomModel) {
			if (this.ComponentVM) {
				this.ComponentVM.model = roomModel.toJSON()
			}
		}

	}

})(window.OCP, window.OCA)
