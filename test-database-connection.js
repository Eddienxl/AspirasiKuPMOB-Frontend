require('dotenv').config();
const { Pengguna, Kategori, Postingan } = require('./models');

async function testDatabaseConnection() {
  try {
    console.log('🔍 Testing connection to new database...');
    console.log('📊 Database URL:', process.env.DATABASE_URL.replace(/:[^:]*@/, ':****@'));
    
    // Test 1: Check existing users
    const userCount = await Pengguna.count();
    console.log(`👥 Total users in database: ${userCount}`);
    
    if (userCount > 0) {
      const users = await Pengguna.findAll({
        attributes: ['id', 'nim', 'nama', 'email', 'peran'],
        limit: 5
      });
      
      console.log('📋 Sample users:');
      users.forEach((user, index) => {
        console.log(`  ${index + 1}. ${user.nama} (${user.email}) - NIM: ${user.nim}`);
      });
    } else {
      console.log('📋 Database is empty - no users found');
    }
    
    // Test 2: Check categories
    const categoryCount = await Kategori.count();
    console.log(`📂 Total categories: ${categoryCount}`);
    
    // Test 3: Check posts
    const postCount = await Postingan.count();
    console.log(`📝 Total posts: ${postCount}`);
    
    // Test 4: Create a test user if database is empty
    if (userCount === 0) {
      console.log('\n🔧 Database is empty, creating initial test user...');
      
      const bcrypt = require('bcrypt');
      const hashedPassword = await bcrypt.hash('password123', 10);
      
      const testUser = await Pengguna.create({
        nim: '12345678901',
        nama: 'Test User',
        email: 'test@example.com',
        kata_sandi: hashedPassword,
        peran: 'pengguna'
      });
      
      console.log('✅ Test user created:', testUser.nama);
    }
    
    console.log('\n✅ Database connection and structure verified!');
    
  } catch (error) {
    console.error('❌ Database test error:', error.message);
    if (error.original) {
      console.error('Original error:', error.original.message);
    }
  } finally {
    process.exit(0);
  }
}

testDatabaseConnection();
