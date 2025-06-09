// Script to reorder categories with Akademik in position 2
require('dotenv').config();
const { Sequelize } = require('sequelize');

// Database connection
const sequelize = new Sequelize(process.env.DATABASE_URL, {
  dialect: 'postgres',
  logging: console.log,
});

async function reorderCategories() {
  try {
    await sequelize.authenticate();
    console.log('✅ Database connected successfully');

    // Define the correct order
    const correctOrder = [
      { id: 1, nama: 'Fasilitas Kampus' },
      { id: 2, nama: 'Akademik' },
      { id: 3, nama: 'Kesejahteraan Mahasiswa' },
      { id: 4, nama: 'Kegiatan Kemahasiswaan' },
      { id: 5, nama: 'Sarana dan Prasarana Digital' },
      { id: 6, nama: 'Keamanan dan Ketertiban' },
      { id: 7, nama: 'Lingkungan dan Kebersihan' },
      { id: 8, nama: 'Transportasi dan Akses' },
      { id: 9, nama: 'Kebijakan dan Administrasi' },
      { id: 10, nama: 'Saran dan Inovasi' }
    ];

    console.log('\n🔄 Starting category reordering...');

    await sequelize.transaction(async (transaction) => {
      // Step 1: Move all IDs to temporary high numbers to avoid conflicts
      console.log('📝 Step 1: Moving to temporary IDs...');
      for (let i = 0; i < correctOrder.length; i++) {
        const tempId = 100 + i + 1;
        await sequelize.query(
          `UPDATE kategori SET id = ${tempId} WHERE nama = '${correctOrder[i].nama}'`,
          { transaction }
        );
        console.log(`   Moved "${correctOrder[i].nama}" to temp ID ${tempId}`);
      }

      // Step 2: Set correct IDs
      console.log('\n📝 Step 2: Setting correct IDs...');
      for (let i = 0; i < correctOrder.length; i++) {
        const tempId = 100 + i + 1;
        const correctId = correctOrder[i].id;
        await sequelize.query(
          `UPDATE kategori SET id = ${correctId} WHERE id = ${tempId}`,
          { transaction }
        );
        console.log(`   Set "${correctOrder[i].nama}" to ID ${correctId}`);
      }

      // Step 3: Reset sequence to avoid future conflicts
      await sequelize.query(
        `SELECT setval(pg_get_serial_sequence('kategori', 'id'), (SELECT MAX(id) FROM kategori))`,
        { transaction }
      );
      console.log('📝 Step 3: Reset ID sequence');
    });

    console.log('\n✅ Category reordering completed successfully!');

    // Show final result
    const [finalCategories] = await sequelize.query(
      `SELECT id, nama FROM kategori ORDER BY id`
    );

    console.log('\n📋 Final category order:');
    const emojis = ['🏫', '📚', '💝', '🎭', '💻', '🛡️', '🌱', '🚌', '📋', '💡'];
    finalCategories.forEach((cat, index) => {
      console.log(`${emojis[index]} ${cat.id}. ${cat.nama}`);
    });

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await sequelize.close();
  }
}

reorderCategories();
