db.crimes.aggregate({
	$lookup: {
		from: "departements",
		localField: "lieu",
		foreignField: "nom",
		as: "departement"
	}
},
{
	$out: "aggregates2"
})