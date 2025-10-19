# Position Scopes - Quick Reference Guide

## 🎯 Status-Based Scopes

```ruby
# Published positions (visible to public)
Position.published
# SQL: WHERE released = true AND online = true

# Draft positions (not yet approved)
Position.draft
# SQL: WHERE released = false AND online = false

# Approved but offline (taken down temporarily)
Position.approved_but_offline
# SQL: WHERE released = true AND online = false

# Active positions
Position.active
# SQL: WHERE is_active = true

# Released (approved by admin)
Position.released
# SQL: WHERE released = true

# Online
Position.online
# SQL: WHERE online = true
```

---

## 🏢 Relationship Scopes

```ruby
# Positions for specific organization
Position.for_organization(org_id)
# Example: Position.for_organization(1)

# Positions for specific university
Position.for_university(uni_id)
# Example: Position.for_university(5)
```

---

## 📝 Type Scopes

```ruby
# Filter by position type
Position.by_type('volunteering')
Position.by_type('freetime')
Position.by_type('university_position')

# Or use enum directly
Position.volunteering
Position.freetime
Position.university_position
```

---

## 👁️ Visibility Scopes

```ruby
# Positions visible to a specific student
Position.visible_to_student(student)
# Handles university visibility logic automatically
```

---

## ⚡ Performance Scopes

```ruby
# Eager load all associations (prevents N+1)
Position.with_associations
# Includes: organization, university, user, FAQs

# Eager load all images
Position.with_images
# Includes: main_picture, picture1, picture2, picture3
```

---

## 🔗 Scope Chaining Examples

```ruby
# Published volunteering positions for organization 1
Position.published.for_organization(1).by_type('volunteering')

# Draft freetime positions with eager loading
Position.draft.by_type('freetime').with_associations

# All published positions with images loaded
Position.published.with_images

# Student-visible positions of specific type
Position.visible_to_student(current_user).by_type('volunteering')

# University positions that are approved but offline
Position.for_university(3).approved_but_offline
```

---

## 📊 Common Use Cases

### **In Controllers:**

```ruby
# Show all published positions for public
def index
  @positions = Position.published.with_associations
end

# Organization dashboard
def dashboard
  @positions = Position.for_organization(current_user.organization_id)
end

# Admin review queue
def pending
  @positions = Position.draft.with_associations
end
```

### **In Views:**

```ruby
# Count by type
<%= Position.by_type('volunteering').count %>

# Filter in view (though better in controller)
<% Position.published.by_type('volunteering').each do |position| %>
  <%= render 'position_card', position: position %>
<% end %>
```

### **In Background Jobs:**

```ruby
# Process all published positions
Position.published.find_each do |position|
  ProcessPositionJob.perform_later(position.id)
end
```

---

## 🎨 Real-World Examples from Your App

### **Example 1: Show Positions Controller**
```ruby
# Before
@positions = Position.where(
  online: true, 
  released: true, 
  organization_id: current_user.organization_id
)

# After
@positions = Position.published.for_organization(current_user.organization_id)
```

### **Example 2: Positions Index View**
```ruby
# Before
volunteering_positions = @positions.where(type: 'volunteering', released: true)

# After
volunteering_positions = @positions.by_type('volunteering').released
```

### **Example 3: API Endpoint**
```ruby
# Before
@positions = Position.where(released: true, online: true)

# After
@positions = Position.published
```

---

## 🚀 Performance Tips

1. **Always use scopes instead of raw where clauses**
   - Scopes use indexes automatically
   - More readable and maintainable

2. **Chain scopes for complex queries**
   ```ruby
   # Good
   Position.published.for_organization(1).by_type('volunteering')
   
   # Avoid
   Position.where(released: true, online: true, organization_id: 1, type: 'volunteering')
   ```

3. **Use eager loading for associations**
   ```ruby
   # Prevents N+1 queries
   Position.published.with_associations
   ```

4. **Use counter caches for counts**
   ```ruby
   # Fast
   organization.positions_count
   
   # Slow
   organization.positions.count
   ```

---

## 🔍 Debugging Scopes

### **See the SQL generated:**
```ruby
Position.published.to_sql
# => "SELECT \"positions\".* FROM \"positions\" WHERE \"positions\".\"released\" = true AND \"positions\".\"online\" = true"
```

### **Explain query performance:**
```ruby
Position.published.explain
# Shows query plan and index usage
```

### **Check if using indexes:**
```ruby
# Look for "Index Scan" in EXPLAIN output
Position.published.by_type('volunteering').explain
```

---

## 📚 Quick Tips

- ✅ **DO** use scopes for reusable queries
- ✅ **DO** chain scopes for readability
- ✅ **DO** eager load associations when needed
- ❌ **DON'T** use raw SQL unless absolutely necessary
- ❌ **DON'T** duplicate query logic across controllers
- ❌ **DON'T** forget about indexes when adding new scopes

---

## 🎓 Advanced: Custom Scope Ideas

Here are some additional scopes you might want to add:

```ruby
# Positions expiring soon
scope :expiring_soon, -> { 
  where(position_temporary: true)
    .where('updated_at < ?', 30.days.ago) 
}

# Recently created
scope :recent, -> { order(created_at: :desc).limit(10) }

# High-skill requirements
scope :high_skill, -> {
  where('creative_skills + technical_skills + social_skills + language_skills + flexibility > ?', 20)
}

# With available slots (if you add capacity tracking)
scope :with_availability, -> { 
  joins(:applications).group('positions.id').having('COUNT(applications.id) < positions.max_capacity') 
}
```

---

**Remember:** Scopes make your code cleaner, faster, and more maintainable! 🚀
