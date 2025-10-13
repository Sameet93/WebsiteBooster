# Trepidus Tech Website

## Overview

This is a corporate website for Trepidus Tech, an IT consulting company. The application is a full-stack web application built with React (TypeScript) on the frontend and Express.js on the backend. It features a modern, responsive design showcasing the company's services, in-house products (CloudCostGuardian), team members, and client testimonials, with a functional contact form that sends emails via SendGrid.

## Recent Changes (October 2025)

**CloudCostGuardian Product Integration**
- Added dedicated Products section showcasing CloudCostGuardian (cloudcostguardian.com)
- CloudCostGuardian: AI-powered FinOps platform for cloud cost management
- Features multi-cloud support (AWS, GCP, Azure), real-time anomaly detection, and instant alerts
- Includes security highlights, integrations showcase, and promotional CTA (6 months free offer)

**In-House Apps Section**
- New section highlighting Trepidus's custom application development capabilities
- Showcases technical expertise in building production-ready applications
- Emphasizes rapid development, enterprise-grade security, and customer-focused approach
- Updated navigation to include Products and In-House Apps links

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

### Frontend Architecture

**Framework & Build System**
- React 18 with TypeScript for type safety and modern component architecture
- Vite as the build tool and development server for fast HMR and optimized production builds
- Wouter for lightweight client-side routing

**UI Components & Styling**
- Radix UI primitives for accessible, unstyled component foundations
- Tailwind CSS v4 (via `@tailwindcss/vite`) for utility-first styling
- shadcn/ui design system with customizable components
- Dark theme by default with CSS custom properties for theming
- Custom theme configuration via `theme.json` for brand consistency

**State Management & Data Fetching**
- TanStack Query (React Query) for server state management and caching
- React Hook Form with Zod validation for form handling
- Custom hooks for mobile responsiveness and toast notifications

**Component Architecture**
- Page-level components in `client/src/pages/` (Home, NotFound)
- Reusable UI components in `client/src/components/`:
  - Header (with updated navigation including Products and In-House Apps)
  - Hero, About, Services
  - **Products** (CloudCostGuardian showcase with features, security, integrations, and CTA)
  - **InHouseApps** (custom development capabilities and technical expertise)
  - Team, Testimonials, Contact, Footer
- Scroll animations using Intersection Observer API for progressive content reveal
- Form validation using Zod schemas with error handling

### Backend Architecture

**Server Framework**
- Express.js with TypeScript for API routes and static file serving
- Vite middleware integration for development with HMR
- Custom logging middleware for API request tracking

**API Design**
- RESTful endpoints under `/api` namespace
- Health check endpoint (`/health`) for container monitoring
- Contact form endpoint (`/api/contact`) with validation
- Centralized error handling with Zod schema validation

**Development vs Production**
- Development: Vite dev server with middleware mode for SSR template rendering
- Production: Pre-built static assets served from `dist/public`
- Environment-based configuration switching

### Data Storage

**Database Setup (Currently Unused)**
- Drizzle ORM configured for PostgreSQL with Neon serverless driver
- Schema defined in `shared/schema.ts` with user model
- Migration system configured via `drizzle.config.ts`
- In-memory storage implementation (`MemStorage`) currently active for user data

**Note**: The database configuration is present but not actively used in the current application. The contact form does not persist data - it only sends emails.

### Email Integration

**SendGrid Service**
- `@sendgrid/mail` library for transactional email
- Email service abstraction in `server/services/email.ts`
- Environment variable configuration for API key (`SENDGRID_API_KEY`)
- Structured email templates with both plain text and HTML formats
- Error handling for missing configuration

### Build & Deployment

**Containerization**
- Docker support with multi-stage builds
- Health check endpoint for container orchestration
- AWS ECS task definition included for cloud deployment

**Build Process**
- Frontend: Vite build outputs to `dist/public`
- Backend: esbuild bundles server code to `dist/index.js`
- Separate commands for development, build, and production modes

**CI/CD Infrastructure**
- GitHub Actions workflows configured (references in documentation)
- AWS deployment options: Elastic Beanstalk and ECS/Fargate
- Environment secrets management via AWS Parameter Store

### Development Tools

**Type Safety & Linting**
- TypeScript with strict mode enabled
- Path aliases configured (`@/` for client, `@shared/` for shared code)
- Incremental compilation for faster builds

**Asset Management**
- Vite asset resolution with `@assets` alias
- Image optimization references in content markdown
- Font loading via Google Fonts (Inter typeface)

## External Dependencies

### Third-Party Services

**SendGrid**
- Purpose: Transactional email delivery for contact form submissions
- Configuration: Requires `SENDGRID_API_KEY` environment variable
- Verified sender email required for production use

**Neon Database** (configured but not active)
- Purpose: Serverless PostgreSQL database
- Configuration: `DATABASE_URL` environment variable expected
- Currently using in-memory storage instead

### Cloud Infrastructure (AWS)

**Amazon ECR (Elastic Container Registry)**
- Docker image storage for deployment
- Required for ECS/Fargate deployments

**Amazon ECS (Elastic Container Service)**
- Container orchestration platform
- Fargate launch type for serverless container execution
- Task definition includes health checks and logging

**AWS Elastic Beanstalk** (alternative deployment)
- Platform-as-a-Service option for simplified deployment
- Deployment scripts provided (`deploy-to-eb.sh`)

**AWS Systems Manager Parameter Store**
- Secure storage for sensitive configuration (e.g., SendGrid API key)
- Referenced in ECS task definitions

**CloudWatch Logs**
- Centralized logging for containerized applications
- Configured in ECS task definition

### Development Dependencies

**Replit Integration**
- Custom Vite plugins for Replit environment
- Development banner script
- Cartographer plugin for code exploration (dev only)
- Runtime error overlay for debugging

### UI Component Libraries

**Radix UI Primitives**
- Accessible component foundations (Dialog, Dropdown, Popover, etc.)
- Unstyled for full design control
- 20+ primitive components included

**Utility Libraries**
- `clsx` and `tailwind-merge` for className composition
- `class-variance-authority` for component variant management
- `date-fns` for date manipulation
- `lucide-react` for icon components