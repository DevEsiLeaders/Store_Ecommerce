package com.mdtalalwasim.ecommerce.controller.rest;

import jakarta.persistence.criteria.Path;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ClassPathResource;
import org.springframework.web.bind.annotation.*;

import com.mdtalalwasim.ecommerce.entity.Category;
import com.mdtalalwasim.ecommerce.service.CategoryService;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.CopyOption;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

@RestController
@RequestMapping("/api")
public class AdminRestController {

	@Autowired
	CategoryService categoryService;

	@PostMapping("/save-category")
	public String saveCategory(@ModelAttribute Category category,
							   @RequestParam("file") MultipartFile file,
							   HttpSession session) {
		// Utilisation d'un nom par défaut si le fichier est vide
		String imageName = !file.isEmpty() ? file.getOriginalFilename() : "default.jpg";
		category.setCategoryImage(imageName);

		if (categoryService.existCategory(category.getCategoryName())) {
			session.setAttribute("errorMsg", "Category Name already Exists");
			return "redirect:/admin/category";
		}

		Category savedCategory = categoryService.saveCategory(category);
		if (savedCategory == null) {
			session.setAttribute("errorMsg", "Not Saved! Internal Server Error!");
		} else {
			if (!file.isEmpty()) {
				try {
					// Récupère le dossier statique et rajoute le sous-dossier "category"
					File baseDir = new ClassPathResource("static/img/category").getFile();
					// Création du dossier s'il n'existe pas
					if (!baseDir.exists()) {
						baseDir.mkdirs();
					}
					Path path = (Path) Paths.get(baseDir.getAbsolutePath(), file.getOriginalFilename());
					System.out.println("File save Path :" + path);
					Files.copy((java.nio.file.Path) file.getInputStream(), (java.nio.file.Path) path, (CopyOption) StandardCopyOption.REPLACE_EXISTING);
				} catch (IOException e) {
					e.printStackTrace();
					session.setAttribute("errorMsg", "File saving error");
					return "redirect:/admin/category";
				}
			}
			session.setAttribute("successMsg", "Category Save Successfully.");
		}
		return "redirect:/admin/category";
	}

}
