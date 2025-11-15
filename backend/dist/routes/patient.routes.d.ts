declare const router: import("express-serve-static-core").Router;
/**
 * @route   GET /api/v1/patients/:id/appointments
 * @desc    Get patient appointments
 * @access  Private
 */
/**
 * @route   GET /api/v1/patients/:id/medical-history
 * @desc    Get patient medical history
 * @access  Private/Doctor/Admin
 */
/**
 * @route   POST /api/v1/patients/:id/medical-records
 * @desc    Add medical record
 * @access  Private/Doctor/Admin
 */
/**
 * @route   GET /api/v1/patients/:id/medical-records
 * @desc    Get patient medical records
 * @access  Private
 */
/**
 * @route   GET /api/v1/patients/:id/statistics
 * @desc    Get patient statistics
 * @access  Private
 */
export default router;
//# sourceMappingURL=patient.routes.d.ts.map