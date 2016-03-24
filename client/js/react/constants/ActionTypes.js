// --------------------------------------------------------
// Users and Roles.
// --------------------------------------------------------
export const SELECT_USER = 'SELECT_USER'

export const LOAD_ALL_USERS_REQUEST = 'LOAD_ALL_USERS_REQUEST'
export const LOAD_ALL_USERS_SUCCESS = 'LOAD_ALL_USERS_SUCCESS'
export const LOAD_ALL_USERS_FAILURE = 'LOAD_ALL_USERS_FAILURE'

export const SAVE_USER_REQUEST = 'SAVE_USER_REQUEST'
export const SAVE_USER_SUCCESS = 'SAVE_USER_SUCCESS'
export const SAVE_USER_FAILURE = 'SAVE_USER_FAILURE'

// Convenience constants for actions, etc.
export const LOAD_ALL_USERS_SET = [LOAD_ALL_USERS_REQUEST, LOAD_ALL_USERS_SUCCESS, LOAD_ALL_USERS_FAILURE]
export const SAVE_USER_SET = [SAVE_USER_REQUEST, SAVE_USER_SUCCESS, SAVE_USER_FAILURE]

// We are informed by the server that another client has changed some data.
export const DATA_CHANGE = 'DATA_CHANGE'

// --------------------------------------------------------
// Notifications.
// --------------------------------------------------------
export const ADD_NOTIFICATION = 'ADD_NOTIFICATION'
export const REMOVE_NOTIFICATION = 'REMOVE_NOTIFICATION'

// --------------------------------------------------------
// Delayed actions.
// --------------------------------------------------------
export const DELAY = 'DELAY'

// --------------------------------------------------------
// Authentication related.
// --------------------------------------------------------
export const LOGIN_REQUESTED = 'LOGIN_REQUESTED'
export const LOGIN_SUCCESS = 'LOGIN_SUCCESS'
export const LOGIN_FAILURE = 'LOGIN_FAILURE'
export const AUTHENTICATION_INIT = 'AUTHENTICATION_INIT'
export const SET_COOKIES = 'SET_COOKIES'
export const SET_IS_AUTHENTICATED = 'SET_IS_AUTHENTICATED'

// Note: will deprecate AUTHENTICATION_UPDATE
//export const AUTHENTICATION_UPDATE = 'AUTHENTICATION_UPDATE'

// --------------------------------------------------------
// Window resize related.
// --------------------------------------------------------
export const WINDOW_RESIZE = 'WINDOW_RESIZE'

// --------------------------------------------------------
// Miscellaneous.
// --------------------------------------------------------
export const SITE_MESSAGE = 'SITE_MESSAGE'
export const SYSTEM_MESSAGE = 'SYSTEM_MESSAGE'
