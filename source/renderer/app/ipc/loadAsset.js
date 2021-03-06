// @flow
import { RendererIpcChannel } from './lib/RendererIpcChannel';
import { LoadAssetChannelName } from '../../../common/ipc/api';
import type {
  LoadAssetRendererRequest,
  LoadAssetMainResponse
} from '../../../common/ipc/api';

// IpcChannel<Incoming, Outgoing>
type LoadAssetChannel = RendererIpcChannel<LoadAssetMainResponse, LoadAssetRendererRequest>
export const loadAssetChannel: LoadAssetChannel = new RendererIpcChannel(LoadAssetChannelName);
