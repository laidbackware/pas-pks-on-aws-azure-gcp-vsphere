# Overview
The repo contains a faily generic implementation of Platform Automation with the goal of being able to deploy to any support cloud provider.
https://docs.pivotal.io/platform-automation/v4.4/

# Warnings 
This is in no way an official implementation of Platform Automation.
This is in no way affiliated with my employer.
Everything is subject to change.
Use a your own risk.

# Requirements
- An ESXi server which is mananged by a vCenters. This is tested against vSphere 6.7
- An S3 blob store pre populated with the VMware ISOs/OVAs
- Concourse CI with a secrets store
- Access to a version control repo containing you copy of  this repo
- A Pivnet account to enable product downloads
- As of NSX-T 3.0, a license allowing install with vsphere

# Instructions
- Secrets must be inserted into the secrets store in the relevant Concourse teams. `1-credhub_set_creds.sh` pulls these from lastpass.
- S3 buckets should setup with names matching the names in `vars/download-vars/download-vars.yml`.
- Update all variables to match you installation.
- Concourse teams setup for each environment. `3-concourse-teams.sh` assumes of DUCC in an ajacent directory.
   https://github.com/laidbackware/ducc
- Set pipelines running `4-set-pipelines.sh`.
- Now the pipelines should be ready to trigger.


# Working Version
| Location          | Product                | Status      | Versions                                 |
|-------------------|------------------------|-------------|------------------------------------------|
| AWS               | TAS                    | Working     | PAS 2\.9                                 |
| AWS               | TKGi \(PKS\)           | Working     | PKS 1\.8                                 |
| Azure             | TAS                    | Not started |                                          |
| Azure             | TKGi \(PKS\)           | Not started |                                          |
| GCP               | TAS                    | Not started |                                          |
| GCP               | TKGi \(PKS\)           | Not started |                                          |
| vSphere \+ NSX\-T | TAS \- Small Footrpint | Not started |                                          |
| vSphere \+ NSX\-T | TKGi \(PKS\)           | Working     | PKS 1\.8, vSphere 6\.7u3, NSX\-T 3\.0\.1 |

# Working Branches
- nsxt-25 - Last working commit with NSX-T 2.5 and vSphere 6.7 before switching to NSX-T 3.0