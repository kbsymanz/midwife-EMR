/* 
 * -------------------------------------------------------------------------------
 * config.js
 *
 * Configuration for the development environment.
 *
 * Usage:
 * 
 * NODE_ENV=development node index.js
 * ------------------------------------------------------------------------------- 
 */

var cfg = require('./config.global')
    // Allows i18n-abide's extract-pot script to pick up these 
    // variables and put them into the pot file.
  , gettext = function(param) {return param;}
  ;

// --------------------------------------------------------
// Site settings.
//
// Note: any attribute that needs localization with the
// templates needs to be added to the i18nLocals() function
// in index.js.
// --------------------------------------------------------
cfg.site.title = gettext('Mercy Maternity');

// --------------------------------------------------------
// Host settings.
// --------------------------------------------------------
cfg.host.port = 3000

// --------------------------------------------------------
// Database settings.
// --------------------------------------------------------
cfg.database.host = 'localhost';
cfg.database.port = 3306;
cfg.database.db = 'mercy1';
cfg.database.dbUser = 'mercy1user';
cfg.database.dbPass = '7JVMeqXAiqTTXdvKCVFfaWmHe';
cfg.database.charset = 'utf8';

// --------------------------------------------------------
// Session settings.
// --------------------------------------------------------
cfg.session.secret = 'ttq5BHqbA4Zhgk48BYL5tyjaz2XTcCAjMkmYEcmaKZd6rave2i';
cfg.session.pool = true;
cfg.session.table = 'session';
cfg.session.cleanup = true;
cfg.session.config = {
  user: cfg.database.dbUser
  , password: cfg.database.dbPass
  , database: cfg.database.db
};

// --------------------------------------------------------
// Cookie settings.
// --------------------------------------------------------
cfg.cookie.secret = 'XDK8cZEAu8QEKE8Bu8abXFxaqjCkgG4HB2sJiXppfnHmnCfigf';
cfg.cookie.maxAge = 60 * 60 * 24 * 1000;    // 1 day


// --------------------------------------------------------
// Path settings: note that these should be set 
// in config.global.js because they do not change depending
// upon the environment.
// --------------------------------------------------------


module.exports = cfg;


