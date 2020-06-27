output "vpn_connection_id" {
  description = "A list with the VPN Connection ID if `create_vpn_connection = true`, or empty otherwise"
  value = module.vpn_gateway.vpn_connection_id
}

output "vpn_connection_tunnel1_address" {
  description = "A list with the the public IP address of the first VPN tunnel if `create_vpn_connection = true`, or empty otherwise"
  value = module.vpn_gateway.vpn_connection_tunnel1_address
}

output "vpn_connection_tunnel1_cgw_inside_address" {
  description = "A list with the the RFC 6890 link-local address of the first VPN tunnel (Customer Gateway Side) if `create_vpn_connection = true`, or empty otherwise"
  value = module.vpn_gateway.vpn_connection_tunnel1_cgw_inside_address
}

output "vpn_connection_tunnel1_vgw_inside_address" {
  description = "A list with the the RFC 6890 link-local address of the first VPN tunnel (VPN Gateway Side) if `create_vpn_connection = true`, or empty otherwise"
  value = module.vpn_gateway.vpn_connection_tunnel1_vgw_inside_address
}

output "vpn_connection_tunnel2_address" {
  description = "A list with the the public IP address of the second VPN tunnel if `create_vpn_connection = true`, or empty otherwise"
  value = module.vpn_gateway.vpn_connection_tunnel2_address
}

output "vpn_connection_tunnel2_cgw_inside_address" {
  description = "A list with the the RFC 6890 link-local address of the second VPN tunnel (Customer Gateway Side) if `create_vpn_connection = true`, or empty otherwise"
  value = module.vpn_gateway.vpn_connection_tunnel2_cgw_inside_address
}

output "vpn_connection_tunnel2_vgw_inside_address" {
  description = "A list with the the RFC 6890 link-local address of the second VPN tunnel (VPN Gateway Side) if `create_vpn_connection = true`, or empty otherwise"
  value = module.vpn_gateway.vpn_connection_tunnel2_vgw_inside_address
}

output "vpn_connection_transit_gateway_attachment_id" {
  description = "The transit gateway attachment ID that was generated when attaching this VPN connection."
  value = module.vpn_gateway.vpn_connection_transit_gateway_attachment_id
}

output "vpn_connection_customer_gateway_configuration" {
  description = "The configuration information for the VPN connection's customer gateway (in the native XML format) if `create_vpn_connection = true`, or empty otherwise"
  value = module.vpn_gateway.vpn_connection_customer_gateway_configuration
}
