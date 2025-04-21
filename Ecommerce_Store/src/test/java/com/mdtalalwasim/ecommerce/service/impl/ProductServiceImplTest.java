package com.mdtalalwasim.ecommerce.service.impl;

import com.mdtalalwasim.ecommerce.entity.Product;
import com.mdtalalwasim.ecommerce.repository.ProductRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.web.multipart.MultipartFile;


import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ProductServiceImplTest {

    @Mock
    ProductRepository productRepository;

    @InjectMocks
    ProductServiceImpl productService;

    Product product;

    @BeforeEach
    void setUp() {
        product = new Product();
        product.setId(1L);
        product.setProductTitle("Title");
        product.setProductDescription("Description");
        product.setProductCategory("Category");
        product.setProductPrice(100.0);
        product.setProductStock(10);
        product.setProductImage("image.png");
        product.setActive(true);
        product.setDiscount(10);
    }

    @Test
    void saveProduct() {
        when(productRepository.save(any(Product.class))).thenReturn(product);
        Product saved = productService.saveProduct(product);
        assertNotNull(saved);
        assertEquals(1L, saved.getId());
        verify(productRepository, times(1)).save(any(Product.class));
    }

    @Test
    void getAllProducts() {
        when(productRepository.findAll()).thenReturn(Collections.singletonList(product));
        List<Product> products = productService.getAllProducts();
        assertNotNull(products);
        assertFalse(products.isEmpty());
        verify(productRepository, times(1)).findAll();
    }

    @Test
    void deleteProduct() {
        when(productRepository.findById(anyLong())).thenReturn(Optional.of(product));
        Boolean result = productService.deleteProduct(1L);
        assertTrue(result);
        verify(productRepository, times(1)).deleteById(1L);
    }

    @Test
    void findById() {
        // Selon l'implémentation, findById retourne toujours Optional.empty()
        Optional<Product> found = productService.findById(1L);
        assertTrue(found.isEmpty());
    }

    @Test
    void getProductById() {
        when(productRepository.findById(anyLong())).thenReturn(Optional.of(product));
        Product found = productService.getProductById(1L);
        assertNotNull(found);
        assertEquals("Title", found.getProductTitle());
        verify(productRepository, times(1)).findById(1L);
    }

    @Test
    void updateProductById() {
        MultipartFile file = mock(MultipartFile.class);
        when(file.isEmpty()).thenReturn(true);
        when(productRepository.findById(anyLong())).thenReturn(Optional.of(product));
        when(productRepository.save(any(Product.class))).thenAnswer(invocation -> invocation.getArgument(0));

        Product update = new Product();
        update.setId(1L);
        update.setProductTitle("Updated Title");
        update.setProductDescription("Updated Description");
        update.setProductCategory("Updated Category");
        update.setProductPrice(150.0);
        update.setProductStock(5);
        update.setDiscount(20);

        Product updated = productService.updateProductById(update, file);
        assertNotNull(updated);
        assertEquals("Updated Title", updated.getProductTitle());
        verify(productRepository, times(1)).save(any(Product.class));
    }

    @Test
    void findAllActiveProducts() {
        when(productRepository.findByIsActiveTrue()).thenReturn(Collections.singletonList(product));
        List<Product> activeProducts = productService.findAllActiveProducts("");
        assertNotNull(activeProducts);
        assertEquals(1, activeProducts.size());
        verify(productRepository, times(1)).findByIsActiveTrue();
    }
}