function(id, type, meta, ctx) {
  if(type == "custom_metadata") {
    if(meta['onedata_json'] && meta['onedata_json']['eml:eml']['dataset']['comment'] == 'model') {
        return [{
            "beginDate": meta['onedata_json']['eml:eml']['dataset']['coverage']['temporalCoverage']['rangeOfDates']['beginDate']['calendarDate'],
            "endDate": meta['onedata_json']['eml:eml']['dataset']['coverage']['temporalCoverage']['rangeOfDates']['endDate']['calendarDate'],
            "region": meta['onedata_json']['eml:eml']['dataset']['coverage']['geographicCoverage']['geographicDescription']
            },
            id
        ];
    }
    return null;

  }

}