{application,ops_node,
             [{description,"An OTP application"},
              {vsn,"0.1.0"},
              {registered,[]},
              {mod,{ops_node_app,[]}},
              {applications,[kernel,stdlib]},
              {env,[]},
              {modules,[oam,ops_appl_operator_server,
                        ops_connect_operator_server,
                        ops_controller_operator_server,ops_db_etcd,
                        ops_install,ops_node,ops_node_app,ops_node_server,
                        ops_node_sup,ops_oam_server,ops_pod,
                        ops_pod_operator_server,ops_ssh,ops_vm]},
              {licenses,["Apache 2.0"]},
              {links,[]}]}.