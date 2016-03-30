net = require 'net'
socks = require 'socks'
vm = require 'vm'
fs = require 'fs'
util = require 'util'
pac = require './pac'
socks = require 'socks'
server = net.createServer (rsock) -> 
    rsock.once 'data' , (data) ->
        rsock.pause()
        headers = data.toString().split(/\r\n/)
        f1stline = headers[0];
        process.stdout.write f1stline
        if f1stline.match /^CONNECT/
            [host,port] = f1stline.split(/\s+/)[1].split(':')
            port ?= 80
            # assume(usually) it's https
            url = "https://#{ host }#{ if port != '443' then ':'+port else '' }/"
            via = pac.FindProxyForURL(url, host)
            process.stdout.write " -> #{via}\n"
            if via.match /^PROXY/i
                [ phost, pport ] = via.split(/\s+/)[1].split(':')
                psock = net.createConnection pport,phost, ->
                    psock.write data
                    psock.pipe rsock
                    rsock.resume() #need call resume to work in 0.10.42
                    rsock.pipe psock
            else if via.match /^SOCKS/i
                [ phost, pport ] = via.split(/\s+/)[1].split(':')
                option = 
                    proxy: ipaddress: phost , port:pport , type: 5
                    target: host: host , port: port
                psock = socks.createConnection option,(error, psock, info)  -> 
                    if error
                        console.error "!< #{error} [url]"
                        rsock.end()
                    else    
                        rsock.write "HTTP/1.1 200 \r\n\r\n"
                        psock.pipe rsock
                        rsock.resume() 
                        rsock.pipe psock
                        psock.resume()
            else
                if not via.match /^DIRECT/i
                    console.error "unknown verdict: #{ via }" 
                psock = net.createConnection port,host, ->
                    rsock.write "HTTP/1.1 200 \r\n\r\n"
                    psock.pipe rsock
                    rsock.resume()
                    rsock.pipe psock
        else #GET/POST/..
            [host,port] = hdl.substr(5).trim().split(':') for hdl in headers[1..] when hdl.match(/^Host:/)
            port ?= 80
            [verb,url,vers] = f1stline.split(/\s+/)
            via = pac.FindProxyForURL(url, host)
            process.stdout.write " -> #{via}\n"
            if via.match /^PROXY/i
                [ phost, pport ] = via.split(/\s+/)[1].split(':')
                psock = net.createConnection pport,phost, ->
                    psock.write data
                    psock.pipe rsock
                    rsock.resume() 
                    rsock.pipe psock
            else if via.match /^SOCKS/i
                [ phost, pport ] = via.split(/\s+/)[1].split(':')
                option = 
                    proxy : ipaddress:phost , port:pport ,type:5
                    target : host:host ,port:port
                psock = socks.createConnection option,(error, psock, info)  -> 
                    if error
                        console.error error
                        rsock.end()
                    else    
                        psock.write data
                        psock.pipe rsock
                        rsock.resume() 
                        rsock.pipe psock
                        psock.resume()
            else
                if not via.match /^DIRECT/i
                    console.error "unknown verdict: #{ via }" 
                psock = net.createConnection port,host, ->
                    psock.write data
                    psock.pipe rsock
                    rsock.resume() 
                    rsock.pipe psock
        rsock.on 'error', (err) ->
            console.log "!> #{err} [#{url}]"
            rsock.end()
        psock.on 'error',(err) ->
            console.log "!< #{err} [#{url}]"
            psock.end()
            rsock.end()
port = process.env.PORT || 8080 
server.listen port,  ->
    console.log "server running:#{ port }"
pacfile=process.argv[2]
if pacfile
    console.log "using pacfile:[#{ pacfile }]"
    try
        vm.runInNewContext( fs.readFileSync( pacfile ), pac ) #console.log util.inspect(pac)
    catch error
        console.log error
        process.exit 1 
