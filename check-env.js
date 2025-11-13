#!/usr/bin/env node

/**
 * Environment Check Script for Zaryah
 * Verifies that all required dependencies and configurations are in place
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('\n🔍 Zaryah Environment Check\n');
console.log('='.repeat(50));

let allChecksPassed = true;

// Helper function to run checks
function checkCommand(command, name, version = false) {
  try {
    const output = execSync(command, { encoding: 'utf-8', stdio: 'pipe' });
    if (version) {
      console.log(`✅ ${name}: ${output.trim()}`);
    } else {
      console.log(`✅ ${name} is installed`);
    }
    return true;
  } catch (error) {
    console.log(`❌ ${name} is NOT installed`);
    allChecksPassed = false;
    return false;
  }
}

// Check Node.js
console.log('\n📦 Checking Prerequisites...\n');
checkCommand('node --version', 'Node.js', true);
checkCommand('npm --version', 'npm', true);

// Check PostgreSQL
const pgCheck = checkCommand('psql --version', 'PostgreSQL', true);
if (!pgCheck) {
  console.log('   💡 Install PostgreSQL: https://www.postgresql.org/download/');
}

// Check Flutter
const flutterCheck = checkCommand('flutter --version', 'Flutter', false);
if (!flutterCheck) {
  console.log('   💡 Install Flutter: https://flutter.dev/docs/get-started/install');
}

// Check for .env file
console.log('\n⚙️  Checking Configuration...\n');
const envPath = path.join(__dirname, '.env');
if (fs.existsSync(envPath)) {
  console.log('✅ .env file exists');

  // Read and check environment variables
  const envContent = fs.readFileSync(envPath, 'utf-8');
  const requiredVars = [
    'DATABASE_URL',
    'JWT_SECRET',
    'ANTHROPIC_API_KEY',
    'PINECONE_API_KEY'
  ];

  requiredVars.forEach(varName => {
    if (envContent.includes(`${varName}=`) &&
        !envContent.includes(`${varName}="your-`) &&
        !envContent.includes(`${varName}=your-`)) {
      console.log(`✅ ${varName} is configured`);
    } else {
      console.log(`⚠️  ${varName} needs to be set in .env`);
      allChecksPassed = false;
    }
  });
} else {
  console.log('❌ .env file not found');
  console.log('   💡 Run: cp .env.example .env');
  allChecksPassed = false;
}

// Check if node_modules exists
console.log('\n📚 Checking Dependencies...\n');
const nodeModulesPath = path.join(__dirname, 'node_modules');
if (fs.existsSync(nodeModulesPath)) {
  console.log('✅ node_modules exists');

  // Check for key dependencies
  const keyDeps = [
    'express',
    '@prisma/client',
    '@anthropic-ai/sdk',
    '@pinecone-database/pinecone',
    'bcrypt',
    'jsonwebtoken'
  ];

  keyDeps.forEach(dep => {
    const depPath = path.join(nodeModulesPath, dep);
    if (fs.existsSync(depPath)) {
      console.log(`✅ ${dep} installed`);
    } else {
      console.log(`❌ ${dep} not installed`);
      allChecksPassed = false;
    }
  });
} else {
  console.log('❌ node_modules not found');
  console.log('   💡 Run: npm install');
  allChecksPassed = false;
}

// Check Prisma
console.log('\n🔧 Checking Prisma...\n');
const prismaClientPath = path.join(__dirname, 'node_modules', '.prisma', 'client');
if (fs.existsSync(prismaClientPath)) {
  console.log('✅ Prisma client generated');
} else {
  console.log('⚠️  Prisma client not generated');
  console.log('   💡 Run: npm run prisma:generate');
}

// Check Flutter dependencies
console.log('\n📱 Checking Flutter App...\n');
const flutterPubspecPath = path.join(__dirname, 'flutter-app', 'pubspec.yaml');
if (fs.existsSync(flutterPubspecPath)) {
  console.log('✅ Flutter pubspec.yaml exists');

  const flutterPackagesPath = path.join(__dirname, 'flutter-app', '.packages');
  if (fs.existsSync(flutterPackagesPath)) {
    console.log('✅ Flutter dependencies installed');
  } else {
    console.log('⚠️  Flutter dependencies not installed');
    console.log('   💡 Run: cd flutter-app && flutter pub get');
  }
} else {
  console.log('❌ Flutter app not found');
}

// Summary
console.log('\n' + '='.repeat(50));
if (allChecksPassed) {
  console.log('\n✅ All checks passed! You\'re ready to run Zaryah.\n');
  console.log('Next steps:');
  console.log('1. Ensure PostgreSQL is running');
  console.log('2. Run: npm run prisma:migrate');
  console.log('3. Run: npm run seed');
  console.log('4. Run: npm start\n');
} else {
  console.log('\n⚠️  Some checks failed. Please fix the issues above.\n');
  console.log('See SETUP_GUIDE.md for detailed setup instructions.\n');
}

process.exit(allChecksPassed ? 0 : 1);
