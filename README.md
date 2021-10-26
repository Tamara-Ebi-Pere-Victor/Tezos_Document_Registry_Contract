# Tezos_Document_Registry_Contract
A replication of my Celo Document Registry in Cameligo

This contract  helps users verify documents that have been issued by an organization. 

The application uses the encryption methods keccak-256 to produce a distinct key that is identifiable to that single issued document.

Only the contract owner and admins have the ability to add documents to the contract. Additionally the contract owner can add addresses that can act as admins and add more documents to the registry.

For verification, the admin and contract owner do not need to pay any fee for verification, only other users do have to pay the fee 0.2tez.

Use Cases
1. This contract can be used by document issuing organizations, like schools, business, e.t.c.
2. It can be used to ensure validity of a perticular document, and help reduce the effect of forgery in the professional world.


Storage Example
{
    docs_2_hash_map : (bytes, timestamp) map ;
    no_of_docs_in_reg : nat ;
    hashes_array : bytes list ;
    admins : (address, bool) map ;
    current_doc_details : document_details ;
}
