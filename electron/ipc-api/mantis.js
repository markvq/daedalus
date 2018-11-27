export const mantisIpcApi = ({ mantis, ipc }) => {
  ipc.on('mantis.start', (event, network) => {
    mantis.start(network);
    event.sender.send('mantis.started', network);
  });

  ipc.on('mantis.stop', (event) => {
    mantis.stop();
    event.sender.send('mantis.stopped');
  });

  ipc.on('mantis.switchTo', (event, network) => {
    mantis.stop()
    mantis.start(network);
    event.sender.send('mantis.started', network);
  });
}
