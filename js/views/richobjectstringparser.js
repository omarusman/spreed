/* global OC, OCA */

/**
 * @copyright (c) 2016 Joas Schilling <coding@schilljs.com>
 *
 * @author Joas Schilling <coding@schilljs.com>
 *
 * This file is licensed under the Affero General Public License version 3 or
 * later. See the COPYING file.
 */

(function(OC, OCA) {

	OCA.SpreedMe.Views.RichObjectStringParser = {

		/**
		 * @param {string} subject
		 * @param {Object} parameters
		 * @returns {string}
		 */
		parseMessage: function(subject, parameters) {
			var self = this,
				regex = /\{([a-z0-9-]+)\}/gi,
				matches = subject.match(regex);

			_.each(matches, function(parameter) {
				parameter = parameter.substring(1, parameter.length - 1);
				if (!parameters.hasOwnProperty(parameter) || !parameters[parameter]) {
					// Malformed translation?
					console.error('Potential malformed ROS string: parameter {' + parameter + '} was found in the string but is missing from the parameter list');
					return;
				}

				var parsed = self.parseParameter(parameters[parameter]);
				subject = subject.replace('{' + parameter + '}', parsed);
			});

			return subject;
		},

		/**
		 * @param {Object} parameter
		 * @param {string} parameter.type
		 * @param {string} parameter.id
		 * @param {string} parameter.name
		 * @param {string} parameter.link
		 */
		parseParameter: function(parameter) {
			switch (parameter.type) {
				case 'user':
					if (!this.userLocalTemplate) {
						this.userLocalTemplate = OCA.Talk.Views.Templates['richobjectstringparser_userlocal'];
					}
					if (!parameter.name) {
						parameter.name = parameter.id;
					}
					if (OC.getCurrentUser().uid === parameter.id) {
						parameter.isCurrentUser = true;
					}
					return this.userLocalTemplate(parameter);

				case 'call':
					if (!this.callTemplate) {
						this.callTemplate = OCA.Talk.Views.Templates['richobjectstringparser_call'];
					}

					return this.callTemplate(parameter);

				case 'file':
					if (!this.filePreviewTemplate) {
						this.filePreviewTemplate = OCA.Talk.Views.Templates['richobjectstringparser_filepreview'];
					}
					return this.filePreviewTemplate(parameter);

				default:
					if (!_.isUndefined(parameter.link)) {
						if (!this.unknownLinkTemplate) {
							this.unknownLinkTemplate = OCA.Talk.Views.Templates['richobjectstringparser_unknownlink'];
						}
						return this.unknownLinkTemplate(parameter);
					}

					if (!this.unknownTemplate) {
						this.unknownTemplate = OCA.Talk.Views.Templates['richobjectstringparser_unknown'];
					}
					return this.unknownTemplate(parameter);
			}
		}

	};

})(OC, OCA);
