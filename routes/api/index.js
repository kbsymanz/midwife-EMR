/*
 * -------------------------------------------------------------------------------
 * index.js
 *
 * All routing modules are exported here.
 * -------------------------------------------------------------------------------
 */
var _ = require('underscore')
  , cfg = require('../../config')
  , User = require('../../models/User').User
  ;

/* --------------------------------------------------------
 * makeMenu()
 *
 * Returns a simple object describing the menu for the client
 * to consume.
 *
 * param       lbl    - the label for the menu item
 * param       url    - the url for the menu item
 * param       server - false for client navigation, true hits server
 * return      Object
 * -------------------------------------------------------- */
var makeMenu = function(lbl, url, server) {
  return {label: lbl, url: url, useServer: server};
}

/* --------------------------------------------------------
 * params()
 *
 * Parameter processing for all API calls. Parses the path
 * and populates the req object with information for
 * downstream processing in req.parameters.
 * -------------------------------------------------------- */
var params = function(req, res, next) {
  req.parameters = {};
  if (req.params.op1) req.parameters.op1 = req.params.op1;
  if (req.params.op2) req.parameters.op2 = req.params.op2;
  if (req.params.op3) req.parameters.op3 = req.params.op3;
  if (req.params.id1) req.parameters.id1 = req.params.id1;
  if (req.params.id2) req.parameters.id2 = req.params.id2;
  return next();
};

var buildMenu = function(req) {
  var menuLeft = []
    , menuRight = []
    , appRev = req.app.locals.applicationRevision
    ;

  if (req.session.user && req.session.user.role) {

    // Leftmost right menu option is the same for everyone.
    //menuRight.push(makeMenu('v' + appRev, '#version', false));  // Meant to be disabled on client.

    // Assign menu items based upon role.
    switch(req.session.user.role.name) {
      case 'administrator':
        menuLeft.push(makeMenu('Users', '/users', false));
        break;
      case 'guard':
        menuLeft.push(makeMenu('Search', '/search', false));
        menuLeft.push(makeMenu('Check In/Out', '/checkinout', false));
        break;
      case 'supervisor':
        menuLeft.push(makeMenu('Search', '/search', false));
        break;
    }

    // The last menu options on the right are the same for everyone.
    menuRight.push(makeMenu('Profile', '/profile', false));
    menuRight.push(makeMenu('Logout', '/logout', true));

    if (menuLeft.length !== 0 || menuRight.length !== 0) {
      return {menuLeft: menuLeft, menuRight: menuRight};
    }
  }
};

/* --------------------------------------------------------
 * doSpa()
 *
 * Determine if the request should load a SPA response or
 * not based upon the role the user has and other criteria.
 * This affords a transition of the application from full
 * page loads to SPA in stages.
 * -------------------------------------------------------- */
var doSpa = function(req, res, next) {
  var appRev = req.app.locals.applicationRevision
    , connSid
    , data
    , newMenu
    , pageName
    ;

  // --------------------------------------------------------
  // Get the connection.sid cookie so that the client can
  // use the data API.
  //
  // NOTE: passing cookies to the client might not be
  // necessary when {credentials: 'same-origin'} is used in
  // the header of the client's call to the server.
  // TODO: remove if not needed.
  // --------------------------------------------------------
  res.req.headers.cookie.split(';').forEach(function(c) {
    var cookie = c.trim();
    var currRole;
    if (/^connect\.sid/.test(cookie)) {
      connSid = cookie.split('=', 2)[1];
    }
  });

  if (req.session.user && req.session.user.role) {

    // --------------------------------------------------------
    // The administrator role is SPA only using the Elm client.
    // --------------------------------------------------------
    if (req.session.user.role.name === 'administrator') {

      // --------------------------------------------------------
      // Store the fact that this user's routes are all SPA.
      // This allows page refreshes to be properly handled.
      // --------------------------------------------------------
      req.session.isSpaOnly = true;

      if (req.url !== '/') {
        return res.redirect('/');
      }

      pageName = 'start_administrator';
      return res.render(pageName);

    } else if (req.session.user.role.name === 'guard') {
      // --------------------------------------------------------
      // The guard is still full page load.
      // --------------------------------------------------------
      return next();

    } else if (req.session.isSpaOnly) {
      // --------------------------------------------------------
      // The current session is flagged as SPA. The flag is set
      // via the route handling for cfg.path.toLabor and
      // cfg.path.toPrenatal. The SPA portion of that route is
      // actualized here.
      // --------------------------------------------------------
      currRole = req.session.user.role.name;
      var data = {};

      // --------------------------------------------------------
      // The request to transition to SPA comes with a pregnancy
      // id to load immediately. Pass that onto the client via
      // an Elm flag.
      // --------------------------------------------------------
      if (req.session.transitionPregId) {
        data.pregId = req.session.transitionPregId;
      }
      req.session.transitionPregId = void 0;

      // --------------------------------------------------------
      // Each role has it's own starting jade page for the sake
      // of customization by role as well as only loading what is
      // necessary for the role.
      // --------------------------------------------------------
      switch (req.session.user.role.name) {
        case 'administrator': {
          pageName = 'start_administrator';
          return res.render(pageName, data);
        }
        case 'guard': {
          pageName = 'start_guard';
          return res.render(pageName, data);
        }
        default: {
          // --------------------------------------------------------
          // Roles one of attending, clerk, or supervisor, which all
          // load the start_medical page.
          //
          // These roles need the list of users loaded into the page.
          // --------------------------------------------------------
          pageName = 'start_medical';
          return User.getUserIdMap()
            .then((map) => {
              data.users = _.values(map);
              data.userId = req.session.user.id;
              data.supervisorId = null;
              if (_.has(req.session, 'supervisor')) data.supervisorId = req.session.supervisor.id;
              return res.render(pageName, data);
            });
        }
      }   // end switch
    }     // end else if
  }

  return next();
}

module.exports = {
  params: params
  , history: require('./history')
  , userRoles: require('./userRoles')
  , spa: require('./spa')
  , search: require('./search')
  , doSpa: doSpa
};
