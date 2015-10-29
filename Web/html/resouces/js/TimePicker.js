function AddPeriod(){
	var fromdate = document.getElementById("FromDate").value;
	var fromtime = document.getElementById("FromTime").value;
	var todate = document.getElementById("ToDate").value;
	var totime = document.getElementById("ToTime").value;
	var from = fromdate + " " + fromtime;
	var to = todate + " " + totime;
	if (fromdate != "" && fromtime!="" && todate!="" && totime!=""){
		var table = document.getElementById("periodTable")
		var rowslen = table.rows.length
		//alert(rowslen)
	
		var row = table.insertRow(rowslen);
		
		var cell1 = row.insertCell(0);
		var cell2 = row.insertCell(1);
	
		var input = document.createElement("input");
		input.type = "text";
		input.name = "startTime["+rowslen+"]";
		input.value = from;
		//input.form = "parameters";
		input.setAttribute("form", "parameters");
		//input.setAttribute("required", true);
		cell1.appendChild(input);

		//cell1.innerHTML = "<input type=\"hidden\" name=\"elem[1][id]\" value=\"1\">";//from;
		var input2 = document.createElement("input");
		input2.type = "text";
		input2.name = "endTime["+rowslen+"]";
		input2.value = to;
		input2.setAttribute("form", "parameters");
		//input2.setAttribute("required", true);
		cell2.appendChild(input2);
		//cell2.innerHTML = to;
	} else
		alert("select interval");

//		<input type="hidden" name="elem[1][id]" value="1"> 
//		<input type="text" name="elem[1][title]" value="First title"> 
	//periodTable
	
}