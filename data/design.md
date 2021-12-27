## Design Document

The goal of the project is to allow a user to upload files and share a link for other people to download them.

With these in mind, here is a sketch of how the app is organized.
UrbitLFS follows the provdier-client design model.
A provider (running `%lfs-provider`) hosts files, and gates access.
A client (running `%lfs-client`) can subscribe to a provider and
upload files to get a public url, which can be shared with whomever.
A client can subscribe to multiple providers at once.

### Happy Path Flow

1. User asks client app to request an upload (create thread from GUI or CLI)
2. Client app sends `%request-upload` to provider to authenticate
3. Provider opens new url for upload on fileserver
4. Provider informs client of private upload url

![show the upload flow](./data/upload-happy-path.svg)

5. Client curls to url to upload file
6. Fileserver tells Provider the client has uploaded
7. Provider gives %fact to subscribers that the file upload succeeded

### Why not these Alternative designs

- direct http server from urbit server
    - 2 GiB clay storage limit
    - all http server downloads stored in log (bloat)
- aws/dropbox/azure
    - integration in future?
- IPFS/sia-coin/blockchain
    - filehoster needs host/stake the files
    - designed for publicity (can't hide that we're sharing a file, even if encrypted)
    - never possible to 'revoke' access

### Related projects

- File hosting service (1-1 or groups)
    - UrbitLFS right now
- File organization
    - selfhosted nextcloud?
- One-off direct peer2peer transfer
    - wormhole.app?
- Peer2Peer sharing
    - torrenting?
- Public document longterm sharing
    - IPFS/SiaCoin?
