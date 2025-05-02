class AddressModel{
  final String address;

  AddressModel({required this.address});

  //fetching from json (backend)
  factory AddressModel.fromJson(Map<String,dynamic>json){
  return AddressModel(address: json['address']);

  }

  ///to json(sending to backend)
Map<String,dynamic> toJson() {
    return{
      'address':address,
    };
}


}