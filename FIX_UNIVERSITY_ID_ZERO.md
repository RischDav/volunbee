# Fix for University ID = 0 Issue

## Problem
User 3 (ge84xah@mytum.de) has `affiliation.university_id = 0`, which points to "Technische Universität München" with `id = 0`.

**ID 0 is invalid** because:
1. Database IDs should start at 1 (standard convention)
2. Position validation explicitly rejects id=0 (line 181-182 in position.rb)
3. Can cause unexpected behavior with Rails associations

## Current Validation That Blocks ID 0

```ruby
# app/models/position.rb line 181-182
if organization_id == 0 || university_id == 0
  errors.add(:base, "❌ Dein Account ist nicht richtig konfiguriert...")
end
```

## Solution Options

### Option 1: Update University ID from 0 to proper value (BEST)
```ruby
# Run in Rails console
uni = University.find(0)
uni.update_column(:id, 1)  # or next available ID

# Update all user affiliations
UserAffiliation.where(university_id: 0).update_all(university_id: 1)

# Update all positions
Position.where(university_id: 0).update_all(university_id: 1)
```

### Option 2: Change validation to allow ID 0
```ruby
# app/models/position.rb
def organization_or_university_present
  if organization.nil? && university.nil?
    errors.add(:base, "❌ Die Position muss entweder einer Organisation oder einer Universität zugeordnet sein.")
  end
end
```

Remove the special check for id==0. This allows id=0 but is non-standard.

### Option 3: Create new University record and migrate users
```ruby
# Create new TUM university with proper ID
new_uni = University.create!(
  name: "Technische Universität München",
  # ... copy other attributes from University.find(0)
)

# Migrate user affiliations
UserAffiliation.where(university_id: 0).update_all(university_id: new_uni.id)

# Delete old university with id=0
University.find(0).destroy
```

## Recommended: Option 2 (Simplest)

Just remove the special check for id=0 in the validation since the university actually exists and works fine.
