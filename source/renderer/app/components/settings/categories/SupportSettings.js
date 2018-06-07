// @flow
import React, { Component } from 'react';
import { observer } from 'mobx-react';
import { defineMessages, intlShape, FormattedMessage } from 'react-intl';
import styles from './SupportSettings.scss';
import IssuesDetection from '../../widgets/IssuesDetection';

const messages = defineMessages({
  faqTitle: {
    id: 'settings.support.faq.title',
    defaultMessage: '!!!Frequently asked questions',
    description: 'Title "Frequently asked questions" on the support settings page.',
  },
  faqContent: {
    id: 'settings.support.faq.content',
    defaultMessage: '!!!If you are experiencing issues, please see the {faqLink} for guidance on known issues.',
    description: 'Content for the "Frequently asked questions" section on the support settings page.',
  },
  faqLink: {
    id: 'settings.support.faq.faqLink',
    defaultMessage: '!!!FAQ on Daedalus website',
    description: '"FAQ on Daedalus website" link in the FAQ section on the support settings page',
  },
  faqLinkUrl: {
    id: 'settings.support.faq.faqLinkURL',
    defaultMessage: '!!!https://daedaluswallet.io/faq/',
    description: 'URL for the "FAQ on Daedalus website" link in the FAQ section on the support settings page',
  },
  reportProblemTitle: {
    id: 'settings.support.reportProblem.title',
    defaultMessage: '!!!Reporting a problem',
    description: 'Title "Reporting a problem" on the support settings page.',
  },
  reportProblemContent: {
    id: 'settings.support.reportProblem.content',
    defaultMessage: '!!!If the FAQ does not solve the issue you are experiencing, please use our {supportRequestLink} feature.',
    description: 'Content for the "Reporting a problem" section on the support settings page.',
  },
  supportRequestLink: {
    id: 'settings.support.reportProblem.link',
    defaultMessage: '!!!Support request',
    description: '"Support request" link in the "Report a problem" section on the support settings page.',
  },
  logsTitle: {
    id: 'settings.support.logs.title',
    defaultMessage: '!!!Logs',
    description: 'Title "Logs" on the support settings page.',
  },
  logsContent: {
    id: 'settings.support.logs.content',
    defaultMessage: '!!!If you want to inspect logs, you can {downloadLogsLink}. Logs do not contain sensitive information, and it would be helpful to attach them to problem reports to help the team investigate the issue you are experiencing. Logs can be attached automatically when using the bug reporting feature.',
    description: 'Content for the "Logs" section on the support settings page.',
  },
  downloadLogsLink: {
    id: 'settings.support.logs.downloadLogsLink',
    defaultMessage: '!!!download them here',
    description: '"download them here" link in the Logs section on the support settings page',
  },
});

type Props = {
  onExternalLinkClick: Function,
  onSupportRequestClick: Function,
  onDownloadLogs: Function,
  issuesDetected: Array
};

@observer
export default class SupportSettings extends Component<Props> {

  static contextTypes = {
    intl: intlShape.isRequired,
  };

  render() {
    const {
      onExternalLinkClick,
      onSupportRequestClick,
      onDownloadLogs,
      issuesDetected
    } = this.props;
    const { intl } = this.context;

    const faqLink = (
      <a
        href={intl.formatMessage(messages.faqLinkUrl)}
        onClick={event => onExternalLinkClick(event)}
      >
        {intl.formatMessage(messages.faqLink)}
      </a>
    );

    const supportRequestLink = (
      <button onClick={onSupportRequestClick}>
        {intl.formatMessage(messages.supportRequestLink)}
      </button>
    );

    const downloadLogsLink = (
      <button onClick={onDownloadLogs}>
        {intl.formatMessage(messages.downloadLogsLink)}
      </button>
    );

    return (
      <div className={styles.component}>

        <IssuesDetection
          onExternalLinkClick={onExternalLinkClick}
          issuesDetected={issuesDetected}
        />

        <h1>{intl.formatMessage(messages.faqTitle)}</h1>

        <p><FormattedMessage {...messages.faqContent} values={{ faqLink }} /></p>

        <h1>{intl.formatMessage(messages.reportProblemTitle)}</h1>

        <p>
          <FormattedMessage {...messages.reportProblemContent} values={{ supportRequestLink }} />
        </p>

        <h1>{intl.formatMessage(messages.logsTitle)}</h1>

        <p><FormattedMessage {...messages.logsContent} values={{ downloadLogsLink }} /></p>

      </div>
    );
  }

}
