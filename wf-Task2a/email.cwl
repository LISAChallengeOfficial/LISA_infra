#!/usr/bin/env cwl-runner
#
# Sends score emails to participants
#
$namespaces:
  s: https://schema.org/

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0002-5841-0198
    s:email: thomas.yu@sagebionetworks.org
    s:name: Thomas Yu

s:contributor:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0002-5622-7998
    s:email: verena.chung@sagebase.org
    s:name: Verena Chung

cwlVersion: v1.0
class: CommandLineTool
baseCommand: python3

hints:
  DockerRequirement:
    dockerPull: sagebionetworks/synapsepythonclient:v2.3.0

inputs:
  - id: submissionid
    type: int
  - id: synapse_config
    type: File
  - id: results
    type: Directory
  - id: private_annotations
    type: string[]?

arguments:
  - valueFrom: score_email.py
  - valueFrom: $(inputs.submissionid)
    prefix: -s
  - valueFrom: $(inputs.synapse_config.path)
    prefix: -c
  - valueFrom: $(inputs.results)
    prefix: -r
  - valueFrom: $(inputs.private_annotations)
    prefix: -p


requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: score_email.py
        entry: |
          #!/usr/bin/env python
          import synapseclient
          import argparse
          import json
          import os
          import glob
          parser = argparse.ArgumentParser()
          parser.add_argument("-s", "--submissionid", required=True, help="Submission ID")
          parser.add_argument("-c", "--synapse_config", required=True, help="credentials file")
          parser.add_argument("-r", "--results", required=True, help="Resulting scores")
          parser.add_argument("-p", "--private_annotations", nargs="+", default=[], help="annotations to not be sent via e-mail")

          args = parser.parse_args()
          syn = synapseclient.Synapse(configPath=args.synapse_config)
          syn.login()

          sub = syn.getSubmission(args.submissionid)
          participantid = sub.get("teamId")
          if participantid is not None:
            name = syn.getTeam(participantid)['name']
          else:
            participantid = sub.userId
            name = syn.getUserProfile(participantid)['userName']
          evaluation = syn.getEvaluation(sub.evaluationId)


          nii_files = glob.glob(os.path.join(args.results, "*.nii.gz"))
          num_files = len(nii_files)
          if num_files == 9:
            subject = f"Submission to '{evaluation.name}' received!"
            message = [f"Hello {name},\n\n",
                      f"Your submission (id: {sub.id}) was successfully received and contains 9 .nii.gz files as expected.",
                      "\n\nThank you for your participation!",
                      "\n\nSincerely,\nChallenge Administrator"]
          else:
            subject = f"Issue with your submission to '{evaluation.name}'"
            message = [f"Hello {name},\n\n",
                      f"Your submission (id: {sub.id}) contains {num_files} .nii.gz file(s), but we expected exactly 9.",
                      "\n\nPlease double-check your submission and re-upload it if needed.",
                      "\n\nSincerely,\nChallenge Administrator"]

          syn.sendMessage(
                  userIds=[participantid],
                  messageSubject=subject,
                  messageBody="".join(message))
          
outputs: []
