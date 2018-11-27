import { spawn, spawnSync } from 'child_process';
import process from 'process';

import psTree from 'ps-tree';

export class Mantis {
  supportedNetworks = ['etc', 'eth'];

  constructor(mantisPath, mantisCmd, mantisArgs) {
    this.mantisProcess = null;
    this.mantisCmd = mantisCmd;
    this.mantisPath = mantisPath;
    this.mantisArgs = mantisArgs;
  }

  start = (networkName) => {
    if (this.mantisProcess) {
      return;
    }

    if (networkName && !this.supportedNetworks.includes(networkName)) {
      throw new Error(`Unsupported network ${networkName}. Supported networks are ${this.supportedNetworks}`);
    }

    Log.info('Starting Mantis...');
    this.mantisProcess = spawn(
      this.mantisCmd,
      [this.mantisArgs].concat(networkName ? [this.getNetworkArg(networkName)] : []),
      { cwd: this.mantisPath, detached: true, shell: true }
    );
  }

  stop = () => {
    if (!this.mantisProcess) {
      return;
    }

    const mantisPid = this.mantisProcess.pid;
    Log.info('Stopping Mantis(PID ' + mantisPid + ')...');
    if (process.platform === 'win32') {
      Log.info('with taskkill');
      spawnSync('taskkill', ['/F', '/T', '/PID', mantisPid], { detached: true }); // Kill main Mantis process
      Log.info('done');
    } else {
      Log.info('with process.kill');
      psTree(mantisPid, (err, children) => {
        // Kill all Mantis child processes
        children.forEach((proc) => {
          Log.info('and child ' + proc.PID);
          process.kill(proc.PID);
        });
      });
      process.kill(mantisPid); // Kill main Mantis process
    }
  }

  getNetworkArg = networkName => `-Dmantis.blockchains.network=${networkName}`
}
