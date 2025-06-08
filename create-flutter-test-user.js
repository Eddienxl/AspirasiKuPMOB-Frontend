require('dotenv').config();
const bcrypt = require('bcrypt');
const { Pengguna } = require('./models');

async function createFlutterTestUser() {
  try {
    console.log('🔧 Creating test user for Flutter app...');
    
    // Check if test user already exists
    const existingUser = await Pengguna.findOne({ where: { email: 'test@example.com' } });
    
    if (existingUser) {
      console.log('✅ Test user already exists:');
      console.log('Email: test@example.com');
      console.log('Password: password123');
      console.log('NIM:', existingUser.nim);
      console.log('Name:', existingUser.nama);
      return;
    }

    // Create test user
    const hashedPassword = await bcrypt.hash('password123', 10);
    
    const testUser = await Pengguna.create({
      nim: '12345678901',
      nama: 'Test User Flutter',
      email: 'test@example.com',
      kata_sandi: hashedPassword,
      peran: 'pengguna'
    });

    console.log('✅ Test user created successfully:');
    console.log('Email: test@example.com');
    console.log('Password: password123');
    console.log('NIM: 12345678901');
    console.log('Name: Test User Flutter');
    
    // Also create a unique user for registration testing
    const uniqueTestUser = await Pengguna.create({
      nim: '99999999999',
      nama: 'Unique Test User',
      email: 'unique@example.com',
      kata_sandi: hashedPassword,
      peran: 'pengguna'
    });

    console.log('\n✅ Unique test user also created:');
    console.log('Email: unique@example.com');
    console.log('Password: password123');
    console.log('NIM: 99999999999');
    console.log('Name: Unique Test User');
    
  } catch (error) {
    console.error('❌ Error creating test user:', error.message);
  } finally {
    process.exit(0);
  }
}

createFlutterTestUser();
