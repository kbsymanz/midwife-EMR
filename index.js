/*
 * -------------------------------------------------------------------------------
 * index.js
 *
 * Mercy - maternal care and patient management.
 * -------------------------------------------------------------------------------
 */

var express = require('express')
  , passport = require('passport')
  , LocalStrategy = require('passport-local').Strategy
  , cons = require('consolidate')
  , roz = require('roz')()
  , grant = roz.grant
  , revoke = roz.revoke
  , where = roz.where
  , anyone = roz.anyone
  , someone = require('auth').someone
  , isAdmin = require('auth').isAdmin
  //, setRoleInfo = require('auth').setRoleInfo
  , app = express()
  , rozed = roz.wrap(app)
  , SessionStore = require('connect-mysql')(express)
  , i18n = require('i18n-abide')
  , _ = require('underscore')
  , cfg = require('./config')
  , path = require('path')
  , User = require('./models').User
  , search = require('./routes').search
  , home = require('./routes').home
  , users = require('./routes').users
  , roles = require('./routes').roles
  , common = []
  ;

// --------------------------------------------------------
// These next three calls are per the example application at:
// https://github.com/jaredhanson/passport-local/blob/master/examples/express3-no-connect-flash/app.js
// --------------------------------------------------------
passport.serializeUser(function(user, done) {
  done(null, user.id);
});

passport.deserializeUser(function(id, done) {
  User.findById(id, function (err, user) {
    done(err, user);
  });
});

passport.use(new LocalStrategy(
  function(username, password, done) {
    //Find the user by username.  If there is no user with the given
    //username, or the password is not correct, set the user to `false` to
    //indicate failure and set a flash message.  Otherwise, return the
    //authenticated `user`.
    User.findByUsername(username, function(err, user) {
      if (err) { return done(err); }
      if (!user) { return done(null, false, { message: 'Unknown user ' + username }); }
      if (user.get('status') != 1) {
        return done(null, false, {
          message: username + ' is not an active account.'
        });
      }
      user.checkPassword(password, function(err, same) {
        if (err) return done(err);
        if (same) {
          return done(null, user);
        } else {
          return done(null, false, {message: 'Invalid password'});
        }
      });
    });
  }
));

// --------------------------------------------------------
// All configurations.
// --------------------------------------------------------
app.engine('jade', cons.jade);
app.set('view engine', 'jade');
app.set('views', path.join(__dirname,'views'));
app.use(express.static('bower_components'));
app.use(express.static('static'));
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.json());
app.use(express.urlencoded());
app.use(express.methodOverride());
app.use(express.cookieParser(cfg.cookie.secret));
app.use(express.session({
  secret: cfg.session.secret
  , cookie: {maxAge: cfg.cookie.maxAge}
  , store: new SessionStore(cfg.session)
}));
app.use(express.bodyParser());
app.use(passport.initialize());
app.use(passport.session());

// --------------------------------------------------------
// Localization.
// --------------------------------------------------------
app.use(i18n.abide({
  supported_languages: ['en-US', 'it-CH']
  , default_lang: 'en-US'
  , debug_lang: 'it-CH'
  , translation_directory: 'static/i18n'
}));

// --------------------------------------------------------
// This is a hack because i18n-abide does not work natively
// outside the context of a request. Therefore, we force
// it into the context of a request in order to localize
// all of the site wide variables for our templates. See
// config.js in the site section.
//
// Note: any additions to cfg.site in config.js need to be
// added to this function.
// --------------------------------------------------------
var i18nLocals = function(req, res, next) {
  app.locals.siteTitle = req.gettext(cfg.site.title);
  next();
};

/* --------------------------------------------------------
 * setRoleInfo()
 *
 * Sets the role information in app.locals so that it is
 * available in all templates rendered.
 *
 * param       req
 * param       res
 * param       cb
 * return      undefined
 * -------------------------------------------------------- */
var setRoleInfo = function(req, res, next) {
  var roles
    , roleInfo = {
      isAuthenticated: req.isAuthenticated()
      , isAdmin: false
      , isStudent: false
      , isSupervisor: false
      , isClerk: false
      , isGuard: false
    }
    ;

  if (req.user && req.user.related) {
    roles = req.user.related('roles');
    roleInfo.isAdmin = roles.findWhere({name: 'administrator'}) ? true: false;
    roleInfo.isStudent = roles.findWhere({name: 'student'}) ? true: false;
    roleInfo.isSupervisor = roles.findWhere({name: 'supervisor'}) ? true: false;
    roleInfo.isClerk = roles.findWhere({name: 'clerk'}) ? true: false;
    roleInfo.isGuard = roles.findWhere({name: 'guard'}) ? true: false;
  }
  app.locals.roleInfo = roleInfo;
  next();
};

// --------------------------------------------------------
// Protect against cross site request forgeries.
// See: http://dailyjs.com/2012/09/13/express-3-csrf-tutorial/
// --------------------------------------------------------
app.use(express.csrf());
function csrf(req, res, next) {
  res.locals.token = req.csrfToken();
  next();
}

app.use(app.router);

// --------------------------------------------------------
// Development configuration
// --------------------------------------------------------
app.configure('development', function() {
  console.log('DEVELOPMENT mode');
  app.use(express.errorHandler());
});

// --------------------------------------------------------
// Production configuration
// --------------------------------------------------------
app.configure('production', function() {
  console.log('PRODUCTION mode');
});

// ========================================================
// ========================================================
// Routes
// ========================================================
// ========================================================

// --------------------------------------------------------
// Group of methods that are commonly needed for
// many requests.
// --------------------------------------------------------
common.push(setRoleInfo, i18nLocals);

// --------------------------------------------------------
// Login and logout
// --------------------------------------------------------
rozed.get(cfg.path.login, roz(grant(anyone)), common, csrf, home.login);
rozed.post(cfg.path.login, roz(grant(anyone)), common, home.loginPost);
rozed.get(cfg.path.logout, roz(grant(someone)), common, home.logout);

// --------------------------------------------------------
// Home
// --------------------------------------------------------
app.get(cfg.path.home, auth, common, home.home);

// --------------------------------------------------------
// Search
// --------------------------------------------------------
rozed.get(cfg.path.search, roz(grant(someone)), common, csrf, search.view);
rozed.post(cfg.path.search, roz(grant(someone)), common, csrf, search.execute);

// --------------------------------------------------------
// Users
// --------------------------------------------------------
rozed.get(cfg.path.userList, roz(grant(isAdmin)), common, users.list);
app.all(cfg.path.userLoad, users.load);  // parameter handling
rozed.get(cfg.path.userNewForm, roz(grant(isAdmin)), common, csrf, users.addForm);
rozed.post(cfg.path.userCreate, roz(grant(isAdmin)), common, csrf, users.create);
rozed.get(cfg.path.userEditForm, roz(grant(isAdmin)), common, csrf, users.editForm);
rozed.post(cfg.path.userUpdate, roz(grant(isAdmin)), common, csrf, users.update);

// --------------------------------------------------------
// Roles
// --------------------------------------------------------
rozed.get(cfg.path.roleList, roz(grant(isAdmin)), common, roles.list);
app.all(cfg.path.roleLoad, roles.load);  // parameter handling
rozed.get(cfg.path.roleNewForm, roz(grant(isAdmin)), common, csrf, roles.addForm);
rozed.post(cfg.path.roleCreate, roz(grant(isAdmin)), common, csrf, roles.create);
rozed.get(cfg.path.roleEditForm, roz(grant(isAdmin)), common, csrf, roles.editForm);
rozed.post(cfg.path.roleUpdate, roz(grant(isAdmin)), common, csrf, roles.update);

// --------------------------------------------------------
// Role assignment to users
// --------------------------------------------------------
app.all(cfg.path.userLoad2, users.load);  // parameter handling
rozed.post(cfg.path.changeRoles, roz(grant(isAdmin)), common, csrf, users.changeRoles);

// --------------------------------------------------------
// Start the server.
// --------------------------------------------------------
app.listen(cfg.host.port);
console.log('Server listening on port ' + cfg.host.port);

/* --------------------------------------------------------
 * auth()
 *
 * param       req
 * param       res
 * param       next
 * return      undefined
 * -------------------------------------------------------- */
function auth(req, res, next) {
  if (req.isAuthenticated()) { return next(); }
  console.log('Redirecting to login');
  res.redirect(cfg.path.login);
}

