require 'net/http'

module OBC
  class Connection

    def post_registrar
      post('/registrar', registrar_payload)
    end

    def deploy(path, *init_args)    # "github.com/openblockchain/obc-peer/openchain/example/chaincode/chaincode_example02", "a", "1000", "b", "2000"
      post('/devops/deploy', deploy_payload(path, *init_args))
    end

    def invoke(chaincode_name, *args)
      post('/devops/invoke', invoke_payload(chaincode_name, *args))
    end

    def query(chaincode_name, *args)
      post('/devops/query', query_payload(chaincode_name, *args))
    end

    private

    attr_reader :http, :user

    def initialize(config)
      @http = Net::HTTP.new(config[:api][:host], config[:api][:port])
      @user = config[:enroll]
    end

    def post(action, to_send)
      request_data = Net::HTTP::Post.new(action, initheader = {'Content-Type' =>'application/json'})
      request_data.body = to_send.to_json
      http.request(request_data)
    end

    def registrar_payload
      {
        enrollId: user[:id],
        enrollSecret: user[:secret]
      }
    end

    def deploy_payload(path, *init_args)
      {
        type: "GOLANG",
        chaincodeID:{
          path: path
        },
        ctorMsg: {
          function:"init",
          args: init_args.map(&:to_s)
        },
        secureContext: user[:id]
      }
    end

    def invoke_payload(chaincode_name, *args)
      {
        chaincodeSpec:
          {
            type: "GOLANG",
            chaincodeID:{
              name: chaincode_name
            },
            ctorMsg: {
              function:"invoke",
              args: args.map(&:to_s)
            },
            secureContext: user[:id]
          }
      }
    end

    def query_payload(chaincode_name, *args)
      {
        chaincodeSpec:
          {
            type: "GOLANG",
            chaincodeID:{
              name: chaincode_name
            },
            ctorMsg: {
              function:"query",
              args:args.map(&:to_s)
            },
            secureContext: user[:id]
          }
      }
    end

  end
end
