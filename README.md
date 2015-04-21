# miniAudicle [![Build Status](https://travis-ci.org/ccrma/miniAudicle.svg?branch=master)](https://travis-ci.org/ccrma/miniAudicle)
## integrated development + performance environment for chuck

See http://audicle.cs.princeton.edu/mini/ for more info!

*OPTIONAL*: You'll need an extra file with a secret key if you want dSYMs (debug symbols files) to be auto-uploaded to Crittercism following each build. This is highly recommended for whoever is making the builds that will be distributed publicly as stack traces will be much more useful with debug symbols. 

* Create a file ".crittercism_keys" in your root user directory: touch ~/.crittercism_keys
* In .crittercism_keys add this: export MINI_AUDICLE_SECRET_KEY="ProtossOP" replacing ProtossOP with the secret key found in the Upload dSYMs tab of the App Settings tab in the Crittercism dashboard.
* Verify the key was exported properly by running this command: source ~/.crittercism_keys && echo $MINI_AUDICLE_SECRET_KEY
