// @flow
import React, { Component, PropTypes } from 'react';
import classNames from 'classnames';
import styles from './WalletHomeButton.scss';

export default class WalletHomeButton extends Component {
  render() {
    const classes = classNames([
      this.props.className, // allow to apply base classes from outside
      this.props.isActive ? styles.active : styles.normal
    ]);
    return (
      <div className={classes}>
        <div className={styles.container}>
          <div className={styles.walletName}>
            {this.props.walletName}
          </div>
          <div className={styles.walletAmount}>
            {this.props.amount} {this.props.currency}
          </div>
        </div>
      </div>
    );
  }
}

WalletHomeButton.propTypes = {
  walletName: PropTypes.string.isRequired,
  amount: PropTypes.number.isRequired,
  currency: PropTypes.string.isRequired,
  isActive: PropTypes.bool.isRequired,
  className: PropTypes.string
};
