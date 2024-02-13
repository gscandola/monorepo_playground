# Idea 1: Polymorphic shell

A single shell, capable to switch (on the fly ? at build time ?) to appropriate MFE.

Solution 1: "dev:form": "MFE_REMOTE_ENTRY=http//... webpack serve --env target=development"
  Env variable target appropriate MFE remoteEntry point
Solution 2: several env file, each per MFE, `.env.form`, `.env.card`...
  Each of these file contains right env varable (url etc) to target the right MFE

Lots of complexity inside the shell, must be built several times with different flags (!= scenarios, != custom props).

Potentially not the best choice.