exports.shExpMatch = function (url,pattern) {
    var pCharCode;
    var isAggressive = false;
    var pIndex;
    var urlIndex = 0;
    var lastIndex;
    var patternLength = pattern.length;
    var urlLength = url.length;
    for (pIndex = 0; pIndex < patternLength; pIndex += 1) {
      pCharCode = pattern.charCodeAt(pIndex); // use charCodeAt for performance, see http://jsperf.com/charat-charcodeat-brackets
      if (pCharCode === 63) { // use if instead of switch for performance, see http://jsperf.com/switch-if
        if (isAggressive) {
          urlIndex += 1;
        }
        isAggressive = false;
        urlIndex += 1;
      } else if (pCharCode === 42) {
        if (pIndex === patternLength - 1) {
          return urlIndex <= urlLength;
        } else {
          isAggressive = true;
        }
      } else {
        if (isAggressive) {
          lastIndex = urlIndex;
          urlIndex = url.indexOf(String.fromCharCode(pCharCode), lastIndex + 1);
          if (urlIndex < 0) {
            if (url.charCodeAt(lastIndex) !== pCharCode) {
              return false;
            }
            urlIndex = lastIndex;
          }
          isAggressive = false;
        } else {
          if (urlIndex >= urlLength || url.charCodeAt(urlIndex) !== pCharCode) {
            return false;
          }
        }
        urlIndex += 1;
      }
    }
    return urlIndex === urlLength;
}

exports.dnsDomainIs = function (host,domain) {

}

exports.isInNet = function (ip,net,mask) {
    return 2 ;
}
exports.myIpAddress = function () {
}
