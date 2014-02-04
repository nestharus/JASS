Importing Instructions
1. Open the map attached to the post
2. Export the model located within it and then import it to your map
3. Copy the unit inside of it and paste it into the target map
4. Change DUMMY_ID into the unit id you assigned to the copied unit
Preface
Provides support for creating and recycling dummy units. Dummy units are recycled into queues based on facing. What this means is that when a dummy unit is created, the allocator will return a dummy unit that is already facing at or close to the desired angle. This behavior is desired as SetUnitFacing does not set a unit's facing instantly. By returning a unit that is already very close to the desired facing, start facing will be almost instant. This is purely a cosmetic effect, but it does look very strange when a projectile is created on a map with the wrong facing, hence the support for recycling with correct facing.
Supports Bribe's MissileRecycler so that people moving over don't have to change everything around ; ).