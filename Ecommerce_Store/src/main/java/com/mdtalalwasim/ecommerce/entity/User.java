package com.mdtalalwasim.ecommerce.entity;

import java.time.LocalDateTime;
import java.util.Date;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Entity
@AllArgsConstructor
@NoArgsConstructor
@Setter
@Getter
@ToString
public class User {
	
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;
	
	private String name;
	
	private String mobile;
	
	private String email;
	
	private String address;
	
	private String city;
	
	private String state;
	
	private String pinCode;
	
	private String password;
	
	private String profileImage;
	
	private String role;
	
	private Boolean isEnable;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getMobile() {
		return mobile;
	}

	public void setMobile(String mobile) {
		this.mobile = mobile;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public String getCity() {
		return city;
	}

	public void setCity(String city) {
		this.city = city;
	}

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}

	public String getPinCode() {
		return pinCode;
	}

	public void setPinCode(String pinCode) {
		this.pinCode = pinCode;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getProfileImage() {
		return profileImage;
	}

	public void setProfileImage(String profileImage) {
		this.profileImage = profileImage;
	}

	public String getRole() {
		return role;
	}

	public void setRole(String role) {
		this.role = role;
	}

	public Boolean getEnable() {
		return isEnable;
	}

	public void setEnable(Boolean enable) {
		isEnable = enable;
	}

	public Boolean getAccountStatusNonLocked() {
		return accountStatusNonLocked;
	}

	public void setAccountStatusNonLocked(Boolean accountStatusNonLocked) {
		this.accountStatusNonLocked = accountStatusNonLocked;
	}

	public Integer getAccountfailedAttemptCount() {
		return accountfailedAttemptCount;
	}

	public void setAccountfailedAttemptCount(Integer accountfailedAttemptCount) {
		this.accountfailedAttemptCount = accountfailedAttemptCount;
	}

	public Date getAccountLockTime() {
		return accountLockTime;
	}

	public void setAccountLockTime(Date accountLockTime) {
		this.accountLockTime = accountLockTime;
	}

	public String getResetTokens() {
		return resetTokens;
	}

	public void setResetTokens(String resetTokens) {
		this.resetTokens = resetTokens;
	}

	public LocalDateTime getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(LocalDateTime createdAt) {
		this.createdAt = createdAt;
	}

	public LocalDateTime getUpdatedAt() {
		return updatedAt;
	}

	public void setUpdatedAt(LocalDateTime updatedAt) {
		this.updatedAt = updatedAt;
	}

	//implement user account lock for wrong password
	private Boolean accountStatusNonLocked;
	
	private Integer accountfailedAttemptCount;
	
	private Date accountLockTime;
	
	private String resetTokens;
	
	@CreationTimestamp
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;
	
	
	
	
}
