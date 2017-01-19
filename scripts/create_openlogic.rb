#!/usr/bin/env ruby

require_relative './../config/environment'

include SystemTrack



class CreateOpenlogic
  OPENLOGIC_ACCOUNT = {name: "Rogue Wave - Openlogic", code: "RW.OPENLOGIC"}
  
  def initialize
    super_user_email = "super.user@company.com"

    user_service = UsersProxy.new
    accounts_service = AccountsProxy.new
    machine_service = MachinesProxy.new
    user_service.ping
    @session = {}
    user_service.sign_in(@session, super_user_email, "secret123")

    accounts = accounts_service.account_list(@session)
    openlogic_account = nil
    accounts.each do |account|
      openlogic_account = account if (account['name'] == OPENLOGIC_ACCOUNT[:name])
    end

    if (!openlogic_account)
      openlogic_account = accounts_service.save(@session, OPENLOGIC_ACCOUNT)
    end
    
    # settings = {
    #   environments: [
    #     {code: 'prod', name: 'Production', category: 'production'},
    #     {code: 'audit', name: 'Audit', category: 'production'},
    #     {code: 'qa', name: 'QA', category: 'test'},
    #     {code: 'perf', name: 'Performance', category: 'test'},
    #     {code: 'uat', name: 'UAT', category: 'test'}
    #   ]
    # }
    
    #openlogic_account['settings'] = settings
    AccountsProxy.new.save(@session, openlogic_account)
    
    @account_id = openlogic_account['id']

    mike = create_user_if_not_exist({account_id: @account_id, email: 'mike.moore@roguewave.com', last_name: 'Moore', first_name: 'Mike', password: 'secret123', password_confirm: 'secret123'})
    eric = create_user_if_not_exist({account_id: @account_id, email: 'eric.weidner@roguewave.com', last_name: 'Weidner', first_name: 'Eric', password: 'secret123', password_confirm: 'secret123'})

    # Create users
    users = user_service.account_users(@session, openlogic_account['id'])
    user_service.sign_in(@session, mike['email'], "secret123")
    
    env = {}
    env[:prod] = save_environment({code: 'prod', name: 'Production', category: 'production'})
    env[:audit] = save_environment({code: 'audit', name: 'Audit', category: 'production'})
    env[:ci] = save_environment({code: 'ci', name: 'CI', category: 'test'})
    env[:qa] = save_environment({code: 'qa', name: 'QA', category: 'test'})
    env[:uat] = save_environment({code: 'uat', name: 'UAT', category: 'test'})
    @env = env

    gitlab_ci = save_service({name: "GitLab CI", code: "gitlab_ci"})
    attach_service_to_environments(gitlab_ci, [env[:ci]])
    
    docker_registry_ci = save_service({name: "Docker Registry", code: "docker_registry"})
    attach_service_to_environments(gitlab_ci, [env[:ci]])

    olex_sql = save_service({name: "Olex MySQL", code: "olex_mysql"})
    attach_service_to_environments(olex_sql, [env[:prod], env[:audit], env[:uat], env[:qa]])

    olex_sql_repl = save_service({name: "Olex MySQL Repl", code: "olex_mysql_repl"})
    attach_service_to_environments(olex_sql_repl, [env[:prod], env[:audit]])
    
    olex_solr = save_service({name: "Olex SOLR", code: "olex_solr"})
    attach_service_to_environments(olex_solr, [env[:prod], env[:audit], env[:uat], env[:qa]])

    olex_solr_repl = save_service({name: "Olex SOLR Repl", code: "olex_solr_repl"})
    attach_service_to_environments(olex_solr_repl, [env[:prod], env[:audit]])

    olex_worker = save_service({name: "Olex Worker", code: "olex_worker"})
    attach_service_to_environments(olex_worker, [env[:prod], env[:audit], env[:uat]])

    olex_web = save_service({name: "Olex Web", code: "olex_worker"})
    attach_service_to_environments(olex_web, [env[:prod], env[:audit], env[:uat]])
    
    scan_worker = save_service({name: "Scan Worker", code: "scan_worker"})
    attach_service_to_environments(olex_worker, [env[:prod], env[:audit], env[:uat]])

    fp_solr = save_service({name: "Fingerprint Solr", code: "fp_solr"})
    attach_service_to_environments(fp_solr, [env[:prod], env[:audit], env[:uat], env[:qa]])

    fp_hbase = save_service({name: "Fingerprint HBase", code: "fp_hbase"})
    attach_service_to_environments(fp_hbase, [env[:prod], env[:audit], env[:uat], env[:qa]])

    fp_bloom = save_service({name: "Fingerprint Bloom", code: "fp_bloom"})
    attach_service_to_environments(fp_bloom, [env[:prod], env[:audit], env[:uat], env[:qa]])

    zookeeper = save_service({name: "Zookeeper", code: "zookeeper"})
    attach_service_to_environments(zookeeper, [env[:prod], env[:audit], env[:uat], env[:qa]])

    olex_redis = save_service({name: "Olex Redis", code: "redis"})
    attach_service_to_environments(olex_redis, [env[:prod], env[:audit], env[:uat], env[:qa]])
    
    olex_resque_web = save_service({name: "Olex Resque Web", code: "resque_web"})
    attach_service_to_environments(olex_resque_web, [env[:prod], env[:audit], env[:uat], env[:qa]])
    

    # Not sure a SAN drive should be a service.
    # san = save_service({name: "SAN Cluster", code: "san"})
    # attach_service_to_environments(zookeeper, [env[:prod]])


    net_10 = save_network({
      name: "10 Net", 
      code: "10", status: NetworkLogic::STATUS[:activated], 
      address: "192.168.10", 
      mask: "255.255.252.0",
     })
    attach_environment_to_network(env[:qa], net_10)
    attach_environment_to_network(env[:ci], net_10)

    net_40 = save_network({
        name: "40 Net", 
        code: "40", 
        status: NetworkLogic::STATUS[:activated], 
        address: "192.168.40", 
        mask: "255.255.252.0", 
        gateway: "192.168.40.1", 
        broadcast: "192.168.40.255",
      })
    attach_environment_to_network(env[:qa], net_40)

    net_50 = save_network({name: "50 Net", code: "50", status: NetworkLogic::STATUS[:activated], 
      address: "192.168.50", 
      mask: "255.255.252.0",
      environments: ["prod", "uat", "audit"]
    })
    attach_environment_to_network(env[:prod], net_50)
    attach_environment_to_network(env[:uat], net_50)
    attach_environment_to_network(env[:audit], net_50)

    net_60 = save_network({name: "60 Net", code: "60", status: NetworkLogic::STATUS[:activated], 
      address: "192.168.60", 
      mask: "255.255.252.0",
      environments: ["prod", "uat", "audit"]
    })
    attach_environment_to_network(env[:prod], net_60)
    attach_environment_to_network(env[:uat], net_60)
    attach_environment_to_network(env[:audit], net_60)

    net_70 = save_network({name: "70 Net", code: "70", 
      status: NetworkLogic::STATUS[:activated], address: "192.168.70", 
      mask: "255.255.252.0",
      environments: ["prod", "uat", "audit"]
    })
    attach_environment_to_network(env[:prod], net_70)
    attach_environment_to_network(env[:uat], net_70)
    attach_environment_to_network(env[:audit], net_70)

    machine_10_61 = save_machine({
      ip_address:  "192.168.10.61", 
      code: "dev-docker-1", 
      brand: "Dell", 
      model: "???",
      os: "coreos",
      network_cards: [
        {ip_address: "192.168.10.61"},
        {ip_address: "192.168.10.62"},
        {ip_address: "192.168.10.63"},
        {ip_address: "192.168.10.64"}
        ]
      },
      net_10
    )

    save_machine({
      ip_address:  "192.168.10.65", 
      code: "dev-docker-2",
      brand: "Dell", 
      model: "???",
      os: "coreos",
      network_cards: [
        {ip_address: "192.168.10.65"},
        {ip_address: "192.168.10.66"},
        {ip_address: "192.168.10.67"},
        {ip_address: "192.168.10.68"}
        ]
      },
      net_10
    )
    
    save_machine({ip_address:  "192.168.10.22", name: "ci3", brand: "Dell", model: "???"}, net_10)
    save_machine({ip_address:  "192.168.10.55", name: "qa-cluster-1", brand: "Dell", model: "???"}, net_10)
    save_machine({ip_address:  "192.168.10.56", name: "qa-cluster-2", brand: "Dell", model: "???"}, net_10)
    save_machine({ip_address:  "192.168.10.57", name: "qa-cluster-3", brand: "Dell", model: "???"}, net_10)
    save_machine({ip_address:  "192.168.10.72", name: "ci", brand: "Dell", model: "???", os: "ubuntu:14.03"}, net_10)
    save_machine({ip_address:  "192.168.10.76", name: "ci2", brand: "Dell", model: "???", os: "ubuntu:14.03"}, net_10)
    
    attach_service_to_machine(fp_solr, machine_with_ip('192.168.10.56'), nil, env[:qa])
    attach_service_to_machine(fp_solr, machine_with_ip('192.168.10.57'), nil, env[:qa])

    attach_service_to_machine(fp_hbase, machine_with_ip('192.168.10.55'), nil, env[:qa])
    attach_service_to_machine(fp_hbase, machine_with_ip('192.168.10.56'), nil, env[:qa])
    attach_service_to_machine(fp_hbase, machine_with_ip('192.168.10.57'), nil, env[:qa])

    attach_service_to_machine(olex_sql, machine_with_ip('192.168.10.61'), nil, env[:qa])
    attach_service_to_machine(olex_redis, machine_with_ip('192.168.10.61'), nil, env[:qa])
    attach_service_to_machine(olex_solr, machine_with_ip('192.168.10.61'), nil, env[:qa])
    attach_service_to_machine(olex_resque_web, machine_with_ip('192.168.10.61'), nil, env[:qa])
    

    save_machine({ip_address:  "192.168.40.21", brand: "Dell", model: "???", os: "ubuntu:14.03"}, net_40)
    save_machine({ip_address:  "192.168.40.24", brand: "Dell", model: "???", os: "ubuntu:14.03"}, net_40)
    save_machine({ip_address:  "192.168.40.30", brand: "Dell", model: "???", os: "ubuntu:14.03"}, net_40)
    save_machine({ip_address:  "192.168.40.31", brand: "Dell", model: "???", os: "ubuntu:14.03"}, net_40)
    save_machine({ip_address:  "192.168.40.32", brand: "Dell", model: "???", os: "ubuntu:14.03"}, net_40)
    save_machine({ip_address:  "192.168.40.35", brand: "Dell", model: "???", os: "ubuntu:14.03"}, net_40)
    save_machine({ip_address:  "192.168.40.50", brand: "Dell", model: "???", os: "ubuntu:14.03"}, net_40)
    
    m_50_13 = save_machine({ip_address:  "192.168.50.13"}, net_50)
    m_50_14 = save_machine({ip_address:  "192.168.50.14"}, net_50)
    m_50_15 = save_machine({ip_address:  "192.168.50.15"}, net_50)

    
    save_machine({ip_address:  "192.168.60.5"}, net_60)
    save_machine({ip_address:  "192.168.60.11", os: "ubuntu:14.03"}, net_60)

    save_machine({ip_address:  "192.168.60.12", os: "ubuntu:14.03"}, net_60)
    attach_service_to_machine(olex_resque_web, machine_with_ip('192.168.60.12'), nil, env[:uat])
    #attach_service_to_machine(olex_sql, machine_with_ip('192.168.60.12'), nil, env[:staging])

    save_machine({ip_address:  "192.168.60.13", os: "ubuntu:14.03"}, net_60)
    
    save_machine({ip_address:  "192.168.60.15", os: "ubuntu:14.03"}, net_60)
    attach_service_to_machine(olex_sql, machine_with_ip('192.168.60.15'), nil, env[:prod])

    save_machine({ip_address:  "192.168.60.33", os: "san"}, net_60)
    save_machine({ip_address:  "192.168.60.34", os: "san"}, net_60)

    
    save_machine({ip_address:  "192.168.60.166", os: "ubuntu:14.03"}, net_60)
    save_machine({ip_address:  "192.168.60.50", os: "ubuntu:14.03"}, net_60)
    
    
    save_machine({ip_address:  "192.168.60.101", os: "ubuntu:14.03"}, net_60)
    attach_service_to_machine(fp_solr, machine_with_ip('192.168.60.101'), nil, env[:prod])
    
    save_machine({ip_address:  "192.168.60.110", os: "ubuntu:14.03"}, net_60)
    save_machine({ip_address:  "192.168.60.111", os: "ubuntu:14.03"}, net_60)
    attach_service_to_machine(fp_bloom, machine_with_ip('192.168.60.110'), nil, env[:audit])
    attach_service_to_machine(olex_sql, machine_with_ip('192.168.60.110'), nil, env[:audit])
    attach_service_to_machine(fp_bloom, machine_with_ip('192.168.60.111'), nil, env[:audit])
    attach_service_to_machine(olex_solr, machine_with_ip('192.168.60.111'), nil, env[:audit])
    
    save_machine({ip_address:  "192.168.60.127", os: "ubuntu:14.03"}, net_60)
    save_machine({ip_address:  "192.168.60.128", os: "ubuntu:14.03"}, net_60)
    save_machine({ip_address:  "192.168.60.129", os: "ubuntu:14.03"}, net_60)
    save_machine({ip_address:  "192.168.60.130", os: "ubuntu:14.03"}, net_60)
    attach_service_to_machine(zookeeper, machine_with_ip('192.168.60.127'), nil, env[:prod])
    attach_service_to_machine(zookeeper, machine_with_ip('192.168.60.128'), nil, env[:prod])
    attach_service_to_machine(zookeeper, machine_with_ip('192.168.60.129'), nil, env[:prod])
    attach_service_to_machine(zookeeper, machine_with_ip('192.168.60.130'), nil, env[:prod])
    
    save_machine({ip_address:  "192.168.60.131", os: "ubuntu:14.03"}, net_60)
    save_machine({ip_address:  "192.168.60.132", os: "ubuntu:14.03"}, net_60)
    save_machine({ip_address:  "192.168.60.133", os: "ubuntu:14.03"}, net_60)
    save_machine({ip_address:  "192.168.60.134", os: "ubuntu:14.03"}, net_60)
    save_machine({ip_address:  "192.168.60.135", os: "ubuntu:14.03"}, net_60)
    attach_service_to_machine(fp_hbase, machine_with_ip('192.168.60.131'), nil, env[:prod])
    attach_service_to_machine(fp_hbase, machine_with_ip('192.168.60.132'), nil, env[:prod])
    attach_service_to_machine(fp_hbase, machine_with_ip('192.168.60.133'), nil, env[:prod])
    attach_service_to_machine(fp_hbase, machine_with_ip('192.168.60.134'), nil, env[:prod])
    attach_service_to_machine(fp_hbase, machine_with_ip('192.168.60.135'), nil, env[:prod])

    save_machine({ip_address:  "192.168.60.141", os: "ubuntu:14.03"}, net_60)
    save_machine({ip_address:  "192.168.60.142", os: "ubuntu:14.03"}, net_60)
    save_machine({ip_address:  "192.168.60.151", os: "ubuntu:14.03"}, net_60)
    save_machine({ip_address:  "192.168.60.152", os: "ubuntu:14.03"}, net_60)
    save_machine({ip_address:  "192.168.60.153", os: "ubuntu:14.03"}, net_60)
    save_machine({ip_address:  "192.168.60.154", os: "ubuntu:14.03"}, net_60)
    attach_service_to_machine(fp_solr, machine_with_ip('192.168.60.141'), nil, env[:prod])
    attach_service_to_machine(fp_solr, machine_with_ip('192.168.60.142'), nil, env[:prod])
    
    attach_service_to_machine(fp_solr, machine_with_ip('192.168.60.151'), nil, env[:audit])
    attach_service_to_machine(fp_solr, machine_with_ip('192.168.60.152'), nil, env[:audit])
    attach_service_to_machine(fp_solr, machine_with_ip('192.168.60.153'), nil, env[:audit])
    attach_service_to_machine(fp_solr, machine_with_ip('192.168.60.154'), nil, env[:audit])
    

    save_machine({ip_address:  "192.168.60.161", os: "ubuntu:14.03"}, net_60)
    save_machine({ip_address:  "192.168.60.162", os: "ubuntu:14.03"}, net_60)
    save_machine({ip_address:  "192.168.60.163", os: "ubuntu:14.03"}, net_60)
    save_machine({ip_address:  "192.168.60.165", os: "ubuntu:14.03"}, net_60)
    attach_service_to_machine(scan_worker, machine_with_ip('192.168.60.161'), nil, env[:prod])
    attach_service_to_machine(scan_worker, machine_with_ip('192.168.60.162'), nil, env[:prod])
    attach_service_to_machine(scan_worker, machine_with_ip('192.168.60.163'), nil, env[:prod])
    attach_service_to_machine(scan_worker, machine_with_ip('192.168.60.165'), nil, env[:prod])

    save_machine({ip_address:  "192.168.60.166", os: "ubuntu:14.03"}, net_60)
    attach_service_to_machine(olex_solr, machine_with_ip('192.168.60.166'), nil, env[:prod])

    save_machine({ip_address:  "192.168.60.164", os: "ubuntu:14.03"}, net_60)
#    attach_service_to_machine(olex_sql, machine_with_ip('192.168.60.164'), nil, env[:staging])
    

    save_machine({ip_address:  "192.168.70.11", os: "ubuntu:14.03"}, net_70)
    attach_service_to_machine(scan_worker, machine_with_ip('192.168.70.11'), nil, env[:audit])

    save_machine({ip_address:  "192.168.70.12", os: "ubuntu:14.03"}, net_70)


    machine_service.attach_service_to_network(@session, olex_sql['id'], net_60['id'])
    machine_service.attach_service_to_network(@session, olex_solr['id'], net_60['id'])
    machine_service.attach_service_to_network(@session, olex_worker['id'], net_60['id'])

    @all_machines = machine_service.machine_list(@session)
    
    # Services for 10 net
    attach_service_to_machine(gitlab_ci, machine_with_ip('192.168.10.61'), nil, env[:ci])
    attach_service_to_machine_card(docker_registry_ci, "192.168.10.63", env[:ci])

    attach_service_to_machine(gitlab_ci, machine_with_ip('192.168.10.65'), nil, env[:ci])
    
    # Services for 60 net
    attach_service_to_machine(olex_sql_repl, machine_with_ip('192.168.60.11'), nil, env[:prod])
    attach_service_to_machine(olex_solr, machine_with_ip('192.168.60.12'), nil, env[:prod])
    attach_service_to_machine(olex_solr, machine_with_ip('192.168.60.166'), nil, env[:prod])
    

    rsa_file = ENV['HOME'] + "/.ssh/id_rsa.pub"
    if (File.exist? rsa_file)
      pub_key = File.read(rsa_file)
      ssh_key = user_service.add_ssh_key(@session, mike['id'], pub_key, "Mike's Mac pub key")
    end
  end
  
  
  def save_environment(environment)
    return MachinesProxy.new.save_environment(@session, environment)
  end

  def attach_service_to_environments(service, environments)
    environments.each do |environment|
      MachinesProxy.new.attach_service_to_environment(@session, service['id'], environment['id'])
    end
  end

  def attach_service_to_machine(service, machine, ip_address, environment)
    #def attach_service_to_machine(session, service_id, machine_id, card_ip_address, environment_code)
    MachinesProxy.new.attach_service_to_machine(@session, service['id'], machine['id'], ip_address, environment['id'])
  end
  
  def attach_service_to_machine_card(service, card_ip_address, environment)
    machine = machine_with_ip(card_ip_address)
    MachinesProxy.new.attach_service_to_machine(@session, service['id'], machine['id'], card_ip_address, environment['id'])
  end

  def save_network(new_network)
    network = MachinesProxy.new.find_network_with_code(@session, new_network[:code])
    if (!network)
      network = MachinesProxy.new.save_network(@session, new_network)
    end
    return network
  end
  
  
  def save_service(service)
    machine_service = MachinesProxy.new
    existing_service = machine_service.find_service_with_code(@session, service[:code])
    if (!existing_service)
      existing_service = machine_service.save_service(@session, service)
    end
    return existing_service
  end

  
  def save_machine(machine, network)
    machine[:name] = machine[:ip_address] if (machine[:name] == nil)
    machine[:code] = machine[:name] if (machine[:code] == nil)
    existing_machine = MachinesProxy.new.find_machine_with_code(@session, machine[:code])
    machine[:id] = existing_machine['id'] if (existing_machine)
    machine[:status] = MachineLogic::STATUS[:activated]
    machine[:network_id] = network['id']
    machine_json = MachinesProxy.new.save_machine(@session, machine)
    if (machine[:network_cards])
      machine[:network_cards].each do |nic|
        MachinesProxy.new.save_machine_network_card(@session, machine_json['id'], nic)
      end
    end
  end

  def machine_with_ip(ip_address)
    return MachinesProxy.new.find_machine_with_ip(@session, @account_id, ip_address)
  end
  
  def find_user(email)
    users = UsersProxy.new.account_users(@session, @account_id)
    matches = users.select {|u| u['email'] == email}
    return matches.first if (matches.length > 0)
    return nil
  end

  def create_user_if_not_exist(user_hash)
    user = find_user(user_hash[:email])
    if (!user)
      user = UsersProxy.new.create_user(@session, user_hash)
    end
    return user
  end
  
  def attach_environment_to_network(environment, network)
    return MachinesProxy.new.attach_environment_to_network(@session, environment['id'], network['id'])
  end
  
  
end


CreateOpenlogic.new
puts "Done"

