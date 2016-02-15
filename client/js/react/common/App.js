import React, {Component} from 'react'
import {Link} from 'react-router'

import TopMenu from './TopMenu'
import {cookies} from '../services/authentication'

// Holds configuration data passed from the outside on initial load.
let cfgData
let cfgToken

class App extends Component {
  constructor(props) {
    super(props)
    this.render = this.render.bind(this)

    // --------------------------------------------------------
    // Get configuration data passed in from the outside.
    // --------------------------------------------------------
    const root = document.getElementById('root')
    cfgData = JSON.parse(root.getAttribute('data-cfg'))

    // --------------------------------------------------------
    // Set the cookies in the store that are needed.
    // --------------------------------------------------------
    cookies(cfgData.cookies)
  }

  render() {
    // --------------------------------------------------------
    // Set the remaining configuration into the props.
    // --------------------------------------------------------
    const siteTitle = cfgData.cfg && cfgData.cfg.siteTitle || 'A Site Title'
    const menuLeft = cfgData.menuLeft || []
    const menuRight = cfgData.menuRight || []
    return (
      <div>
        <TopMenu siteTitle={siteTitle} menuLeft={menuLeft} menuRight={menuRight} />
        <div className='container'>
          {this.props.children}
        </div>
      </div>
    )
  }
}

export default App
