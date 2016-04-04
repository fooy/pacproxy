function shExpMatch(url,pattern) {
    var plen = pattern.length;
    var nlen = url.length;
    for (var pidx = 0,nidx=0; pidx < plen; pidx++,nidx++ ) {
        var p = pattern.charCodeAt(pidx); 
        switch ( p ) {
            case 63: //?
                if(nidx >= nlen) return false;
                break;
            case 42: //*
                if(pidx === plen -1 ) return true;
                for( p = pattern.charCodeAt(++pidx) ;( p === 42 || p === 63 ) && (pidx < plen) ; p = pattern.charCodeAt(++pidx) ) {
                    if( p === '?' ){
                        if( nidx == nlen -1 ) return false;
                        else nidx++ ;
                    }
                }
                for ( ; nidx<nlen ; nidx++ ){
                    if ( p === url.charCodeAt(nidx) && shExpMatch( url.substr(nidx), pattern.substr(pidx) ) )
                        return true;
                }
                return false;
                break;
            default:
                if ( p != url.charCodeAt(nidx) )
                    return false;
                break;
        }
    }
    return nidx === nlen;
}

exports.shExpMatch = shExpMatch ;

exports.dnsDomainIs = function (host,domain) {
}
exports.dateRange= function (start,end) {
}
exports.weekdayRange =function( start,end) {
}
exports.isInNet = function (ip,net,mask) {
}
exports.myIpAddress = function () {
}

function tests( t, p ,r) {
    var cases = [
        [ "hhh.abc.com/sfjkdjksfd","*?c*?com*", true ],
        [ "abc.1.com/", "*abc.*.com/*", true ],
        [ "abc.1.com/adfs","*abc.*.com/*" , true ],
        [ "abc.1.com/adfs","abc.1.com/adf?" ,true],
        [ "abc.1.com/adf","abc.1.com/adf?" ,false],
        [ "abc.1.com/adf","",false] ];
    for ( var k in cases )
    {
        var i= cases[k];
        var r=shExpMatch ( i[0], i[1] )
        console.log (i[0] + " ~ " + i[1] +"\t"+r  + "-> " + ( r=== i[2] ? "pass":"error" ))
    }
}
