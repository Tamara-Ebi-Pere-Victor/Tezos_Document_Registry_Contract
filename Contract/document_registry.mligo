type addParameter = bytes
type verifyParameter = bytes
type newAdminParameter = address

type entryPoints = 
| AddDocument of addParameter
| VerifyDocument of verifyParameter
| AddAdmin of newAdminParameter

type document_details = {
    publish_date : timestamp ;
    output : unit -> operation list
}

type registry_storage = {
    docs_2_hash_map : (bytes, timestamp) map ;
    no_of_docs_in_reg : nat ;
    hashes_array : bytes list ;
    admins : (address, bool) map ;
    current_doc_details : document_details ;
}

type return = operation list * registry_storage

let owner_address : address = 
    ("tz1hx1MnUh1bj9AnFi6BMrCuoXBiZ2p2fG5T" : address)

let add_document(origin_Hash, store : bytes * registry_storage) : return =
    // Check if user is owner address
    let () = if Tezos.source <> owner_address then
        failwith "Only Organization Account is Allowed to add documents to the Blockchain"
    in

    // Get the publish time
    let timeAdded : timestamp = Tezos.now in

    // encode the hash gotten from the frontend
    let hash_bytes : bytes = Crypto.keccak origin_Hash in

    // Add hash to documents_to_hash map
    let docs_2_hash_map : (bytes, timestamp) map = 
        Map.add hash_bytes timeAdded store.docs_2_hash_map
    in

    // Adding the hash_bytes to the list of hashes
    let hashes : bytes list = hash_bytes :: store.hashes_array in

    //Update storage with the new values

    let store = { store with 
        docs_2_hash_map = docs_2_hash_map ;
        no_of_docs_in_reg = abs (store.no_of_docs_in_reg + 1) ;
        hashes_array = hashes ;
        } 
    in
(([] : operation list), store)

let verify_document(client_side_hash, store : bytes * registry_storage) : return =
    // get user address
    let user_address : address =  Tezos.source in

    // check if the user is an admin
    let isAdmin : bool =
        match Map.find_opt user_address store.admins with
        | Some x -> x
        | None -> false
    in

    // if user is not an admin
    let () = if isAdmin <> true
    then
        // ensure that they are paying the verification amount
        let () = if Tezos.amount <= 0.2tez then
            failwith "Sorry Fee not enough for verification"
        in () in
    
    // encode the hash again
    let hash_bytes : bytes = Crypto.keccak client_side_hash in

    // check the document time
    let doc_publication_time : timestamp = 
        match Map.find_opt hash_bytes store.docs_2_hash_map with
        | Some i -> i
        | None -> (failwith "Document does not exist in chain" : timestamp)
    in
    
(([] : operation list), store)


let add_admin(new_address, store : address * registry_storage) : return =
    // Check if user is owner address
    let () = if Tezos.source <> owner_address then
        failwith "Only Organization Account is Allowed to add new admins"
    in

    // Add new admin
    let new_admin : (address, bool) map = 
        Map.add new_address true store.admins
    in
    
    // Updating the storage
    let store = { store with 
        admins = new_admin
        } 
    in
(([] : operation list), store)

let main (action, store : entryPoints * registry_storage) : return =
    match action with 
    | AddDocument param -> add_document (param, store)
    | VerifyDocument param -> verify_document (param, store)
    | AddAdmin param -> add_admin (param, store)
