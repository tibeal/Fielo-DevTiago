var testCases = document.querySelector('#bottomPanel-body').querySelectorAll('.x-grid-cell-inner');

var texts = '';
testCases.forEach(function(div) {
    if ( div.innerText.indexOf('FieloELR')!=-1 || div.innerText.indexOf('ELR')!=-1)
	    texts += div.innerText + '\n';
});


console.log(texts);