package com.mdtalalwasim.ecommerce.controller.rest;

import com.mdtalalwasim.ecommerce.entity.ProductOrder;
import com.mdtalalwasim.ecommerce.service.ProductOrderService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
@Controller
@RequestMapping("/admin")
public class AdminOrderController {

    @Autowired
    private ProductOrderService productOrderService;

    @GetMapping("/manage-orders")
    public String manageOrders(Model model) {
        List<ProductOrder> orders = productOrderService.getAllOrders();
        model.addAttribute("orders", orders);
        return "admin/orders/manage-orders";
    }

    @GetMapping("/order/{orderId}")
    public String viewOrderDetails(@PathVariable String orderId, Model model) {
        ProductOrder order = productOrderService.getOrderById(orderId);
        model.addAttribute("order", order);
        return "admin/order-details";
    }

    @PostMapping("/update-order-status")
    public String updateOrderStatus(@RequestParam String orderId,
                                    @RequestParam String status,
                                    RedirectAttributes redirectAttributes) {
        ProductOrder updatedOrder = productOrderService.updateOrderStatus(orderId, status);
        if (updatedOrder != null) {
            redirectAttributes.addFlashAttribute("successMsg", "Order status updated successfully");
        } else {
            redirectAttributes.addFlashAttribute("errorMsg", "Failed to update order status");
        }
        return "redirect:/admin/manage-orders";
    }
}
