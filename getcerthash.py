#!/usr/bin/python

#- hosts: localhost
#  tasks:
#    - name: Get Cert Hash
#      getcerthash:
#        certificate_file: "cert.pem"
#      register: result
#
#    - debug: var=result

from ansible.module_utils.basic import *
import commands


def getcerthash(data):

# do stuff

def main():

    fields = {
        "certificate_file": {"required": True, "type": "str"}
    }

    certificate_file = data['certificate_file']

    fields = {"certificate_file": {"required": True, "type": "str"}}

    certhash = subprocess.check_output("openssl x509 -in" + certificate_file + " -noout -sha1 -fingerprint",stderr=subprocess.STDOUT,shell=True)
    sha_text,sha_value = certhash.split('=')
    certhash_str = sha_value.rstrip().replace(":","")

    module = AnsibleModule(argument_spec={})
    response = {"hello": certhash_str}
    module.exit_json(changed=True, meta=response)

if __name__ == '__main__':
    main()

