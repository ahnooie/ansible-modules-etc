#!/usr/bin/python

#- hosts: localhost
#  tasks:
#    - name: Get Cert Hash
#      getcerthash:
#        certificate_file: "/etc/ssl/certs/cert.pem"
#        hash_algorithm: sha1
#      register: result
#
#    - debug: var=result

from ansible.module_utils.basic import *
import commands

def getcerthash(data):

    certificate_file = data['certificate_file']
    hash_algorithm = data['hash_algorithm']
    certhash = subprocess.check_output("openssl x509 -in " + certificate_file + " -noout -"+ hash_algorithm + " -fingerprint",stderr=subprocess.STDOUT,shell=True)
    sha_text,sha_value = certhash.split('=')
    certhash_str = sha_value.rstrip().replace(":","")
    result = {"fingerprint": certhash_str}

    return False, True, result

def main():

    fields = {
        "certificate_file": {"required": True, "type": "str"},
        "state": {"required": True, "type": "str"},
        "hash_algorithm": {"required": True, "type": "str"}
    }

    choice_map = { 
        "present": getcerthash
    }

    module = AnsibleModule(argument_spec=fields)
    is_error, has_changed, result = choice_map.get(
        module.params['state'])(module.params)

    if not is_error:
        module.exit_json(changed=has_changed, meta=result)
    else:
        module.fail_json(msg="There was an error", meta=result)


if __name__ == '__main__':
    main()

