# Test Positions Created

**Date:** October 19, 2025  
**User:** ge84xah@mytum.de (User ID: 3)  
**University:** Technische Universität München (ID: 0)

## Created Positions

### 1. Volunteering Position (ID: 4)
- **Type:** volunteering
- **Title:** Ehrenamtliche Nachhilfe für Studierende
- **Description:** Volunteer tutoring for students - helping with various subjects, preparing learning materials, conducting individual or group sessions
- **Benefits:** Gain teaching experience, expand university network, receive certificate, contribute to educational equity
- **Weekly hours:** 4 hours
- **Temporary:** No
- **Skills:** Creative=2, Technical=3, Social=5, Language=4, Flexibility=3
- **Status:** Draft (Offline)
- **Main picture:** Not attached

### 2. Freetime Position (ID: 5)
- **Type:** freetime
- **Title:** Campus Yoga & Meditation Gruppe
- **Description:** Relaxation after stressful university life - yoga and meditation sessions twice weekly for beginners and advanced
- **Benefits:** Free participation, professional guidance, nice community, stress relief, improved flexibility and concentration
- **Weekly hours:** 3 hours
- **Temporary:** No
- **Skills:** Creative=3, Technical=3, Social=3, Language=3, Flexibility=3
- **Status:** Draft (Offline)
- **Main picture:** Not attached

### 3. University Position (ID: 6)
- **Type:** university_position
- **Title:** Studentische Hilfskraft IT-Support
- **Description:** TUM seeks student assistant for IT support - first-level support, IT infrastructure management, software installation and maintenance
- **Benefits:** Fair pay according to TV-L, practical IT experience, flexible hours, insights into university IT, good work atmosphere
- **Weekly hours:** 10 hours
- **Temporary:** Yes
- **Payment:** 12-15 EUR/Stunde nach TV-L
- **Visibility:** university (only TUM students can see)
- **Skills:** Creative=3, Technical=5, Social=4, Language=3, Flexibility=4
- **Status:** Draft (Offline)
- **Main picture:** Not attached

## Database Status

✅ **Data is persisted** - All positions are saved in the database  
✅ **No migration needed** - Data is ready to use  
✅ **Server is running** - Positions are accessible immediately

## How to Test

### 1. Login as the test user:
- Email: `ge84xah@mytum.de`
- You'll see 3 draft positions in your dashboard

### 2. Edit each position:
- Click "Edit" button on any position
- The controller will render the appropriate edit form:
  - **Volunteering** → `volunteering/edit.html.erb`
  - **Freetime** → `freetime/edit.html.erb`
  - **University Position** → `university_position/edit.html.erb`

### 3. Add images and publish:
- Upload a main_picture (required)
- Optionally upload picture1, picture2, picture3
- Save the position
- Mark as "released" to make it visible to admins
- Mark as "online" to make it visible to students

### 4. Test character count validation:
- Type in title field → see real-time character count
- Type in description field → see warning if too short/long
- Type in benefits field → same validation

## Edit Action Flow

When you click "Edit" on a position:

```
GET /positions/:id/edit
  ↓
PositionsController#edit
  ↓
Load @position (ID: 4, 5, or 6)
  ↓
Check @position.type
  ↓
├─ "volunteering" → render 'volunteering/edit'
├─ "freetime" → render 'freetime/edit'
└─ "university_position" → render 'university_position/edit'
```

## What to Verify

- [ ] All three positions appear in the dashboard
- [ ] Edit button works for each position type
- [ ] Correct edit form is rendered for each type
- [ ] Character count validation shows real-time feedback
- [ ] Error messages appear when validation fails
- [ ] Can upload images successfully
- [ ] Can save and update positions
- [ ] Type badge appears correctly on position show page

## Notes

- Positions created in **draft mode** (released=false, online=false)
- This bypasses the main_picture requirement
- You can add images through the UI
- All positions belong to Technische Universität München (ID: 0)
- University position visibility is set to "university" (only TUM students)

## Technical Details

**Creation Method:** `Position.new(...).save(validate: false)`  
**Reason:** main_picture validation is strict - bypassed for testing  
**Impact:** No impact on functionality - can be edited and published normally

