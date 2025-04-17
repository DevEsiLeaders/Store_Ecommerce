package com.mdtalalwasim.ecommerce.service;

import com.mdtalalwasim.ecommerce.entity.ProductOrder;
import com.mdtalalwasim.ecommerce.entity.ProductOrderRequest;

import java.util.List;

public interface ProductOrderService {

	public ProductOrder saveProductOrder(Long id, ProductOrderRequest productOrderRequest);

	public List<ProductOrder> getAllOrders();

	public ProductOrder getOrderById(String orderId);

	public ProductOrder updateOrderStatus(String orderId, String status);
}