---
title: Codesigning for Windows binaries
linkTitle: Codesigning
description: >
  We distribute signed CLI binaries (.exe) for Windows. Here is how to configure CI and the CLI repository, and how to update the certificate once it expires.
---

## Ensure creation of signed binaries

Distributing a signed binary (aka codesigning) requires the following things. If all is in place, signed Windows binaries are created with every release. If something is missing, unsigned binaries are created instead.

- A code signing certificate available as GitHub repository action secrets and variables
- The repository flavor set to `cli`

### Preparing your repository in giantswarm/github

Make sure to set `flavour: cli` in your repository configuration, like in [this example](https://github.com/giantswarm/github/blob/v0.28.0/repositories/team-rainbow.yaml#L101).

### Preparing the CLI repository

1. Open the repository containing your CLI code.

2. Go to the _Settings > Security > Secrets and variables_ page for this repository.

3. Check if there are two `CODE_SIGNING_CERT_BUNDLE_*` repository secrets.

   If they are missing:

   1. Open our password manager and find the "code signing" entry.
   2. Copy the P12 bundle password and create a new repository secret named `CODE_SIGNING_CERT_BUNDLE_PASSWORD` with the copied password as the value.
   3. Download the ZIP attachment.
   4. Unzip the ZIP content, so that you have the P12 file.
   5. Continue as described below, under "Updating the certificate", step (4), to create the `CODE_SIGNING_CERT_BUNDLE_BASE64` secret.

## Updating the certificate

1. First, get a replacement certificate from our certificate authority (SSL.com).

2. Follow the SSL.com documentation

   The documentation page [Ordering And Retrieving Code Signing and EV Code Signing Certificates](https://www.ssl.com/how-to/ordering-and-retrieving-code-signing-certificates/) details how to obtain a P12 file from SSL.com.

   The last time we replaced our cert, we contacted support and could enter the process at step 27.

   In the process, you will have to set a password for the P12 bundle. Please generate a secure pass phrase using a tool.

3. Create a new credential in our password manager

   Store a ZIP file of the P12 bundle in the password manager, too.

4. Create a base64 version of the P12 file

   On mac OS, this is done using `cat file.p12 | base64`.

5. Set GitHub repo action secrets

   In your CLI's Github repository, go to Settings > Security > Secrets variables > Actions.

   Here, in the _Repository secrets_ section, create two new entries:

   - `CODE_SIGNING_CERT_BUNDLE_BASE64` with the base64 code representing the P12 file.

   - `CODE_SIGNING_CERT_BUNDLE_PASSWORD` with the password of the P12 bundle you set before.

